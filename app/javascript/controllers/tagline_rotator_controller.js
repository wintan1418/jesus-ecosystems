import { Controller } from "@hotwired/stimulus"

// Rotates through child [data-tagline] elements with a slide-up + fade
// crossfade. Honors prefers-reduced-motion and respects an optional
// `interval` value in milliseconds.
export default class extends Controller {
  static values = { interval: { type: Number, default: 2800 } }
  static targets = ["item"]

  connect() {
    if (this.itemTargets.length === 0) return
    this.index = 0
    this.activate(this.index)

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  next() {
    const prev = this.index
    this.index = (this.index + 1) % this.itemTargets.length
    this.deactivate(prev)
    this.activate(this.index)
  }

  activate(i)   { this.itemTargets[i].dataset.active = "true" }
  deactivate(i) { delete this.itemTargets[i].dataset.active }
}
