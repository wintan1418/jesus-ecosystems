import { Controller } from "@hotwired/stimulus"
import Hls from "hls.js"

// Plays an HLS .m3u8 stream as a muted, looping, autoplaying background video.
// Falls back to native HLS in Safari, hls.js elsewhere. Hides on error so the
// poster image / Ken Burns slideshow takes over. Exposes #toggleMute and emits
// a "playing" class on the root once the video has started so the UI can
// reveal a status indicator.
export default class extends Controller {
  static values = { src: String }
  static targets = ["video", "muteIcon", "tapHint"]

  connect() {
    const v = this.hasVideoTarget ? this.videoTarget : this.element
    if (!v || !this.srcValue) return

    v.muted = true
    v.playsInline = true
    v.autoplay = true
    v.loop = true
    v.preload = "metadata"
    v.setAttribute("playsinline", "true")
    v.setAttribute("webkit-playsinline", "true")

    const tryPlay = () =>
      v.play().then(() => this.markPlaying()).catch(() => this.showTapHint())

    if (v.canPlayType("application/vnd.apple.mpegurl")) {
      v.src = this.srcValue
      v.addEventListener("loadedmetadata", tryPlay, { once: true })
    } else if (Hls.isSupported()) {
      this.hls = new Hls({ enableWorker: true, lowLatencyMode: false })
      this.hls.loadSource(this.srcValue)
      this.hls.attachMedia(v)
      this.hls.on(Hls.Events.MANIFEST_PARSED, tryPlay)
      this.hls.on(Hls.Events.ERROR, (_, data) => {
        if (data.fatal) this.handleFailure()
      })
    } else {
      this.handleFailure()
    }

    v.addEventListener("playing", () => this.markPlaying(), { once: true })
  }

  disconnect() {
    if (this.hls) {
      this.hls.destroy()
      this.hls = null
    }
  }

  markPlaying() {
    this.element.classList.add("is-playing")
    if (this.hasVideoTarget) this.videoTarget.classList.add("is-playing")
    this.element.dataset.state = "playing"
  }

  showTapHint() {
    if (this.hasTapHintTarget) this.tapHintTarget.dataset.visible = "true"
  }

  // Called by the unmute button or a tap on the hero
  toggleMute(event) {
    if (event) event.preventDefault()
    const v = this.videoTarget
    v.muted = !v.muted

    // First user gesture often unblocks autoplay too
    if (v.paused) v.play().then(() => this.markPlaying()).catch(() => {})

    if (this.hasMuteIconTarget) {
      this.muteIconTarget.textContent = v.muted ? "🔇" : "🔊"
    }
    if (this.hasTapHintTarget) delete this.tapHintTarget.dataset.visible
  }

  handleFailure() {
    this.element.classList.add("hls-failed")
  }
}
