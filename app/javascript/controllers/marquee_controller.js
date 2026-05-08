import { Controller } from "@hotwired/stimulus"

// rAF-driven marquee that can smoothly slow on hover instead of pausing.
// Replaces the CSS @keyframes scroll. We translate the inner track left at
// `pxPerSec` * speedFactor each frame, looping at half-width (which matches
// the "double the content" pattern the markup already uses).
export default class extends Controller {
  static targets = ["track"]
  static values  = {
    pxPerSec:    { type: Number, default: 60 },
    hoverFactor: { type: Number, default: 0.25 }
  }

  connect() {
    this.targetFactor  = 1
    this.currentFactor = 1
    this.offset        = 0
    this.last          = performance.now()

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      // Static — show the first half so content is still readable.
      return
    }

    // Stop the CSS keyframe so we can drive it from JS.
    this.trackTarget.style.animation = "none"
    this.trackTarget.style.willChange = "transform"

    this.onEnter = () => { this.targetFactor = this.hoverFactorValue }
    this.onLeave = () => { this.targetFactor = 1 }
    this.element.addEventListener("pointerenter", this.onEnter)
    this.element.addEventListener("pointerleave", this.onLeave)

    this.tick = this.tick.bind(this)
    this.raf  = requestAnimationFrame(this.tick)
  }

  disconnect() {
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.onEnter) this.element.removeEventListener("pointerenter", this.onEnter)
    if (this.onLeave) this.element.removeEventListener("pointerleave", this.onLeave)
  }

  tick(now) {
    const dt = (now - this.last) / 1000
    this.last = now

    // Ease the speed factor toward the hover/idle target.
    this.currentFactor += (this.targetFactor - this.currentFactor) * Math.min(1, dt * 3.5)

    this.offset -= this.pxPerSecValue * this.currentFactor * dt
    const half = this.trackTarget.scrollWidth / 2
    if (half > 0 && this.offset <= -half) this.offset += half

    this.trackTarget.style.transform = `translate3d(${this.offset}px, 0, 0)`
    this.raf = requestAnimationFrame(this.tick)
  }
}
