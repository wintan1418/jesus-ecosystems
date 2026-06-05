import { Controller } from "@hotwired/stimulus"

// Turns the testimonial rows into REAL horizontal scrollers that also
// auto-advance on their own. The visitor can grab-and-drag (mouse), swipe
// (touch), or trackpad-scroll any row at any time; auto-scroll pauses while
// they interact and gently resumes after a short idle.
//
// The seamless loop works because each row's cards are duplicated 2x in the
// markup — when scrollLeft passes the half-way point we jump back by half the
// scroll width, which is visually identical.
export default class extends Controller {
  static values = {
    speed: { type: Number, default: 28 },   // auto-scroll px per second
    idle:  { type: Number, default: 2000 }  // ms of stillness before resuming
  }

  connect() {
    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.rows = Array.from(this.element.querySelectorAll(".letter-wall-row"))
    this.cleanups = []

    this.rows.forEach((row) => {
      row.dataset.paused = "false"
      const dir = row.dataset.direction === "right" ? -1 : 1
      row.dataset.dir = dir
      // Right-moving rows start at the midpoint so they have runway to scroll back.
      if (dir === -1) row.scrollLeft = row.scrollWidth / 2
      this.bindRow(row)
    })

    if (!this.reduced) {
      this.lastTime = null
      this.tick = this.tick.bind(this)
      this.frame = requestAnimationFrame(this.tick)
    }
  }

  disconnect() {
    if (this.frame) cancelAnimationFrame(this.frame)
    this.cleanups.forEach((fn) => fn())
  }

  tick(now) {
    if (this.lastTime == null) this.lastTime = now
    // Clamp dt so a backgrounded tab doesn't fling the rows on return.
    const dt = Math.min((now - this.lastTime) / 1000, 0.05)
    this.lastTime = now

    this.rows.forEach((row) => {
      if (row.dataset.paused === "true") return
      row.scrollLeft += Number(row.dataset.dir) * this.speedValue * dt
      this.wrap(row)
    })

    this.frame = requestAnimationFrame(this.tick)
  }

  // Keep scrollLeft inside [0, half] so the duplicated content loops invisibly.
  wrap(row) {
    const half = row.scrollWidth / 2
    if (half <= 0) return
    if (row.scrollLeft >= half) row.scrollLeft -= half
    else if (row.scrollLeft <= 0) row.scrollLeft += half
  }

  bindRow(row) {
    let isDown = false
    let resumeTimer = null

    const pause = () => { row.dataset.paused = "true" }
    const scheduleResume = () => {
      clearTimeout(resumeTimer)
      resumeTimer = setTimeout(() => { row.dataset.paused = "false" }, this.idleValue)
    }

    // Mouse: real grab-and-pull. Touch/pen: let native scrolling do the work,
    // we only pause/resume the auto-advance.
    const onPointerDown = (e) => {
      pause()
      if (e.pointerType === "mouse") {
        isDown = true
        row.classList.add("is-grabbing")
        row.setPointerCapture?.(e.pointerId)
      }
    }
    const onPointerMove = (e) => {
      if (!isDown) return
      row.scrollLeft -= e.movementX
      this.wrap(row)
    }
    const endDrag = () => {
      if (isDown) { isDown = false; row.classList.remove("is-grabbing") }
      scheduleResume()
    }
    const onPassiveInput = () => { pause(); scheduleResume() } // wheel / touch swipe

    row.addEventListener("pointerdown", onPointerDown)
    row.addEventListener("pointermove", onPointerMove)
    row.addEventListener("pointerup", endDrag)
    row.addEventListener("pointercancel", endDrag)
    row.addEventListener("wheel", onPassiveInput, { passive: true })
    row.addEventListener("touchstart", onPassiveInput, { passive: true })
    row.addEventListener("touchmove", onPassiveInput, { passive: true })

    this.cleanups.push(() => {
      clearTimeout(resumeTimer)
      row.removeEventListener("pointerdown", onPointerDown)
      row.removeEventListener("pointermove", onPointerMove)
      row.removeEventListener("pointerup", endDrag)
      row.removeEventListener("pointercancel", endDrag)
      row.removeEventListener("wheel", onPassiveInput)
      row.removeEventListener("touchstart", onPassiveInput)
      row.removeEventListener("touchmove", onPassiveInput)
    })
  }
}
