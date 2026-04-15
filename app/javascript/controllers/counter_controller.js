import { Controller } from "@hotwired/stimulus"

// Counts from 0 (or `from`) to `to` over `duration` ms once the element
// scrolls into view. Use [data-counter-target="value"] for the numeric span.
export default class extends Controller {
  static values = {
    to:       Number,
    from:     { type: Number, default: 0 },
    duration: { type: Number, default: 1400 },
    suffix:   { type: String, default: "" }
  }
  static targets = ["value"]

  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting && !this.started) {
          this.started = true
          this.run()
          this.observer.disconnect()
        }
      })
    }, { threshold: 0.4 })
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  run() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.set(this.toValue)
      return
    }
    const start = performance.now()
    const tick = (now) => {
      const t = Math.min(1, (now - start) / this.durationValue)
      const eased = 1 - Math.pow(1 - t, 3) // easeOutCubic
      const v = Math.round(this.fromValue + (this.toValue - this.fromValue) * eased)
      this.set(v)
      if (t < 1) requestAnimationFrame(tick)
    }
    requestAnimationFrame(tick)
  }

  set(v) {
    if (this.hasValueTarget) this.valueTarget.textContent = `${v}${this.suffixValue}`
  }
}
