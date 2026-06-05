import { Controller } from "@hotwired/stimulus"

// Turns the testimonial rows into REAL horizontal scrollers that also
// auto-advance on their own — all three rows continuously, like the original
// CSS marquee. The visitor can grab-and-drag (mouse) or swipe (touch);
// auto-scroll pauses while they interact and resumes after a short idle.
//
// WHY THE ROWS USED TO FREEZE ON DESKTOP
// --------------------------------------
// The markup renders one "set" of cards per row. A seamless loop needs the
// track to be WIDER than the viewport, otherwise `scrollLeft` saturates at
// `scrollWidth - clientWidth` and the row pins to its edge for most of the
// loop — which looked like the middle row going static while the others moved.
// With only a few letters per row, one set (~1000px) is narrower than a wide
// desktop viewport (~1440-1920px), so it clamped. Phones (~390px) never hit
// this, which is why mobile was perfect and desktop broke.
//
// THE FIX
// -------
// On connect we measure one set's pitch and CLONE it until the track is
// comfortably wider than the viewport (>= clientWidth + 2 units). Then we wrap
// the scroll position by that measured unit. This adapts to any screen width
// and any number of letters — no guessing a duplication count in the markup.
//
// Position is tracked in a JS float accumulator (this.offsets), NOT read back
// from scrollLeft each frame: scrollLeft rounds to whole pixels, so a
// sub-pixel per-frame step (~0.5px at 60fps) would truncate to 0 and the wall
// would barely creep.
export default class extends Controller {
  static values = {
    speed: { type: Number, default: 32 },   // auto-scroll px per second
    idle:  { type: Number, default: 1200 }  // ms of stillness before resuming
  }

  connect() {
    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.rows = Array.from(this.element.querySelectorAll(".letter-wall-row"))
    this.offsets = new Map()
    this.units = new Map()
    this.cleanups = []

    this.rows.forEach((row) => {
      row.dataset.paused = "false"
      row.dataset.dir = row.dataset.direction === "right" ? -1 : 1
      this.offsets.set(row, 0)
      this.fillRow(row)
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

  // Measure one set's pitch, then clone the set until the track extends at
  // least two units past the viewport so wrapping never reveals an edge.
  fillRow(row) {
    const track = row.querySelector(".letter-wall-track")
    if (!track) return

    const original = Array.from(track.children)
    if (original.length === 0) return

    // Clone once so we can measure the true per-set pitch (card widths + the
    // flex gap that joins one set to the next).
    original.forEach((node) => track.appendChild(node.cloneNode(true)))
    const unit = track.children[original.length].offsetLeft - track.children[0].offsetLeft
    if (unit <= 0) { this.units.set(row, 0); return }

    // Keep cloning until the track is comfortably wider than the viewport.
    let guard = 0
    while (track.scrollWidth < row.clientWidth + unit * 2 && guard < 12) {
      original.forEach((node) => track.appendChild(node.cloneNode(true)))
      guard++
    }

    this.units.set(row, unit)
  }

  tick(now) {
    if (this.lastTime == null) this.lastTime = now
    // Clamp dt so a backgrounded tab doesn't fling the rows on return.
    const dt = Math.min((now - this.lastTime) / 1000, 0.05)
    this.lastTime = now

    this.rows.forEach((row) => {
      if (row.dataset.paused === "true") return
      const unit = this.units.get(row)
      if (!unit) return
      const next = this.wrap(this.offsets.get(row) + Number(row.dataset.dir) * this.speedValue * dt, unit)
      this.offsets.set(row, next)
      row.scrollLeft = next
    })

    this.frame = requestAnimationFrame(this.tick)
  }

  // Keep a position inside [0, unit) so the cloned sets loop invisibly.
  wrap(v, unit) {
    return ((v % unit) + unit) % unit
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
        const unit = this.units.get(row)
        this.offsets.set(row, unit ? this.wrap(row.scrollLeft, unit) : row.scrollLeft)
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
      const unit = this.units.get(row)
      const next = startScroll - (e.clientX - startX)
      row.scrollLeft = unit ? this.wrap(next, unit) : next
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
    // the behaviour the owner approved.)
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
