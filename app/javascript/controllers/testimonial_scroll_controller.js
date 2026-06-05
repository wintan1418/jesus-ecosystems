import { Controller } from "@hotwired/stimulus"

// Turns the testimonial rows into REAL horizontal scrollers that also
// auto-advance on their own — all three rows continuously, like the original
// CSS marquee. The visitor can grab-and-drag (mouse), swipe (touch), or
// trackpad-scroll horizontally; auto-scroll pauses while they interact and
// resumes after a short idle.
//
// Position is tracked in a JS float accumulator (this.offsets), NOT read back
// from scrollLeft each frame: scrollLeft rounds to whole pixels, so a
// sub-pixel per-frame step (~0.5px at 60fps) would truncate to 0 and the wall
// would barely creep.
//
// IMPORTANT (desktop): we only pause on *horizontal* wheel intent. Vertical
// mouse-wheel page scrolling must never pause a row, or rows freeze for the
// idle window as you scroll past — which looked like the middle row going
// static while the others moved.
//
// The seamless loop works because each row's cards are duplicated 2x in the
// markup — at the half-way point we wrap by half the scroll width.
export default class extends Controller {
  static values = {
    speed: { type: Number, default: 32 },   // auto-scroll px per second
    idle:  { type: Number, default: 1200 }  // ms of stillness before resuming
  }

  connect() {
    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.rows = Array.from(this.element.querySelectorAll(".letter-wall-row"))
    this.offsets = new Map()
    this.cleanups = []

    this.rows.forEach((row) => {
      row.dataset.paused = "false"
      row.dataset.dir = row.dataset.direction === "right" ? -1 : 1
      // Start every row at 0; reverse rows wrap to the midpoint on frame 1.
      this.offsets.set(row, 0)
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
      const half = row.scrollWidth / 2
      if (half <= 0) return
      const next = this.wrapValue(this.offsets.get(row) + Number(row.dataset.dir) * this.speedValue * dt, half)
      this.offsets.set(row, next)
      row.scrollLeft = next
    })

    this.frame = requestAnimationFrame(this.tick)
  }

  // Keep a position inside [0, half) so the duplicated content loops invisibly.
  wrapValue(v, half) {
    if (v >= half) return v - half
    if (v < 0) return v + half
    return v
  }

  bindRow(row) {
    let isDown = false
    let startX = 0
    let startScroll = 0
    let resumeTimer = null

    const pause = () => { row.dataset.paused = "true" }
    const scheduleResume = () => {
      clearTimeout(resumeTimer)
      resumeTimer = setTimeout(() => {
        // Re-sync the accumulator to wherever the visitor left it.
        this.offsets.set(row, row.scrollLeft)
        row.dataset.paused = "false"
      }, this.idleValue)
    }

    // Mouse: real grab-and-pull via clientX delta. Touch/pen: native scrolling
    // does the work — we only pause/resume the auto-advance.
    const onPointerDown = (e) => {
      if (e.pointerType !== "mouse") { pause(); return }
      isDown = true
      startX = e.clientX
      startScroll = row.scrollLeft
      row.classList.add("is-grabbing")
      row.setPointerCapture?.(e.pointerId)
      pause()
    }
    const onPointerMove = (e) => {
      if (!isDown) return
      const half = row.scrollWidth / 2
      row.scrollLeft = this.wrapValue(startScroll - (e.clientX - startX), half)
    }
    const endDrag = () => {
      if (isDown) { isDown = false; row.classList.remove("is-grabbing") }
      scheduleResume()
    }

    // Only react to horizontal wheel intent (trackpad sideways swipe). Vertical
    // page scrolling must be ignored so rows don't freeze as you scroll past.
    const onWheel = (e) => {
      if (Math.abs(e.deltaX) <= Math.abs(e.deltaY)) return
      pause()
      scheduleResume()
    }
    // Touch: pause while finger is down, resume after release. (Mobile path —
    // intentionally left as-is; it's the behaviour the owner approved.)
    const onTouch = () => { pause(); scheduleResume() }

    row.addEventListener("pointerdown", onPointerDown)
    row.addEventListener("pointermove", onPointerMove)
    row.addEventListener("pointerup", endDrag)
    row.addEventListener("pointercancel", endDrag)
    row.addEventListener("wheel", onWheel, { passive: true })
    row.addEventListener("touchstart", onTouch, { passive: true })
    row.addEventListener("touchmove", onTouch, { passive: true })

    this.cleanups.push(() => {
      clearTimeout(resumeTimer)
      row.removeEventListener("pointerdown", onPointerDown)
      row.removeEventListener("pointermove", onPointerMove)
      row.removeEventListener("pointerup", endDrag)
      row.removeEventListener("pointercancel", endDrag)
      row.removeEventListener("wheel", onWheel)
      row.removeEventListener("touchstart", onTouch)
      row.removeEventListener("touchmove", onTouch)
    })
  }
}
