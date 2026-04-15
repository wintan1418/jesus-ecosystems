import { Controller } from "@hotwired/stimulus"

// Custom HTML5 audio player.
//
// hls.js is loaded LAZILY only when the source is an .m3u8 stream — that way
// a flaky CDN can't break the controller for plain MP3 sources, and the import
// failure is logged + visible in the UI instead of silently no-op'ing every
// button.
export default class extends Controller {
  static targets = ["audio", "playBtn", "playIcon", "progress", "fill", "elapsed", "remaining", "title", "status"]
  static values  = { storageKey: { type: String, default: "soe-audio-pos" } }

  connect() {
    this.audioTarget.preload = "metadata"
    this.audioTarget.addEventListener("timeupdate",     () => this.tick())
    this.audioTarget.addEventListener("loadedmetadata", () => { this.tick(); this.setStatus("ready") })
    this.audioTarget.addEventListener("playing",        () => this.setPlaying(true))
    this.audioTarget.addEventListener("pause",          () => this.setPlaying(false))
    this.audioTarget.addEventListener("ended",          () => this.setPlaying(false))
    this.audioTarget.addEventListener("error",          (e) => {
      console.error("[audio-player] audio element error", e, this.audioTarget.error)
      this.setError(this.audioTarget.error?.message || "audio failed to load")
    })
    document.addEventListener("keydown", this.onKey = this.onKey.bind(this))

    // Pre-select the first track so the big play button has something to play.
    this.firstTrack = this.element.querySelector("[data-audio-track]")
    if (this.firstTrack) this.loadTrack(this.firstTrack, { autoplay: false })
  }

  disconnect() {
    if (this.hls) this.hls.destroy()
    document.removeEventListener("keydown", this.onKey)
  }

  // ─── public actions ─────────────────────────────────────────────────────
  load(event) {
    event.preventDefault()
    this.loadTrack(event.currentTarget, { autoplay: true })
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (!this.currentId && this.firstTrack) {
      this.loadTrack(this.firstTrack, { autoplay: true })
      return
    }

    if (this.audioTarget.paused) {
      this.audioTarget.play()
        .then(() => this.setPlaying(true))
        .catch((err) => {
          console.error("[audio-player] play() rejected", err)
          this.setError(err.message || "playback blocked")
        })
    } else {
      this.audioTarget.pause()
    }
  }

  seek(event) {
    const rect = this.progressTarget.getBoundingClientRect()
    const pct  = (event.clientX - rect.left) / rect.width
    if (this.audioTarget.duration) {
      this.audioTarget.currentTime = pct * this.audioTarget.duration
    }
  }

  // ─── internals ──────────────────────────────────────────────────────────
  async loadTrack(trigger, { autoplay = true } = {}) {
    const url   = trigger.dataset.audioUrl
    const title = trigger.dataset.audioTitle || ""
    const id    = trigger.dataset.audioId

    if (!url) {
      this.setError("track missing data-audio-url")
      return
    }

    this.element.classList.remove("has-error")
    this.setStatus("loading")

    if (this.hls) { this.hls.destroy(); this.hls = null }

    const isHls = /\.m3u8(\?|$)/i.test(url)

    if (isHls && !this.audioTarget.canPlayType("application/vnd.apple.mpegurl")) {
      try {
        const mod = await import("hls.js")
        const Hls = mod.default || mod
        if (Hls.isSupported()) {
          this.hls = new Hls()
          this.hls.loadSource(url)
          this.hls.attachMedia(this.audioTarget)
          this.hls.on(Hls.Events.ERROR, (_, data) => {
            if (data.fatal) {
              console.error("[audio-player] hls fatal", data)
              this.setError("HLS stream failed: " + data.type)
            }
          })
        } else {
          this.setError("HLS not supported in this browser")
          return
        }
      } catch (err) {
        console.error("[audio-player] hls.js import failed", err)
        this.setError("audio engine failed to load")
        return
      }
    } else {
      // Plain MP3/WAV/etc — just set the src.
      this.audioTarget.src = url
    }

    this.currentId = id
    if (this.hasTitleTarget) this.titleTarget.textContent = title

    const saved = this.savedPosition(id)
    if (saved) {
      this.audioTarget.addEventListener("loadedmetadata", () => {
        this.audioTarget.currentTime = saved
      }, { once: true })
    }

    if (autoplay) {
      this.audioTarget.play()
        .then(() => this.setPlaying(true))
        .catch((err) => {
          console.warn("[audio-player] autoplay rejected, waiting for click", err)
        })
    }

    document.querySelectorAll("[data-audio-track]").forEach((el) => {
      el.dataset.active = (el.dataset.audioId === id) ? "true" : "false"
    })
  }

  tick() {
    const a = this.audioTarget
    if (!a.duration || isNaN(a.duration)) return
    const pct = (a.currentTime / a.duration) * 100
    this.fillTarget.style.width = pct + "%"
    if (this.hasElapsedTarget)   this.elapsedTarget.textContent   = this.fmt(a.currentTime)
    if (this.hasRemainingTarget) this.remainingTarget.textContent = "-" + this.fmt(a.duration - a.currentTime)
    if (this.currentId && a.currentTime > 1) this.savePosition(this.currentId, a.currentTime)
  }

  setPlaying(playing) {
    if (this.hasPlayIconTarget) this.playIconTarget.textContent = playing ? "❚❚" : "▶"
    this.element.dataset.state = playing ? "playing" : "paused"
    if (playing) this.setStatus("playing")
  }

  setStatus(state) {
    if (this.hasStatusTarget) this.statusTarget.textContent = state
  }

  setError(msg) {
    this.element.classList.add("has-error")
    this.setPlaying(false)
    if (this.hasStatusTarget) this.statusTarget.textContent = `error: ${msg}`
  }

  onKey(e) {
    if (e.code === "Space" && document.activeElement.tagName !== "INPUT") {
      e.preventDefault()
      this.toggle()
    }
  }

  fmt(secs) {
    if (!secs || isNaN(secs)) return "0:00"
    const m = Math.floor(secs / 60)
    const s = Math.floor(secs % 60)
    return `${m}:${s.toString().padStart(2, "0")}`
  }

  savePosition(id, t) {
    try {
      const data = JSON.parse(localStorage.getItem(this.storageKeyValue) || "{}")
      data[id] = t
      localStorage.setItem(this.storageKeyValue, JSON.stringify(data))
    } catch (_) {}
  }

  savedPosition(id) {
    try {
      const data = JSON.parse(localStorage.getItem(this.storageKeyValue) || "{}")
      return data[id] || 0
    } catch (_) {
      return 0
    }
  }
}
