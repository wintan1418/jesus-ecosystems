import { Controller } from "@hotwired/stimulus"

// Crossfades through child [data-ken-burns-target="slide"] images,
// each applying a slow zoom-and-pan. The CSS animation is in app.css.
export default class extends Controller {
  static values = { interval: { type: Number, default: 6500 } }
  static targets = ["slide"]

  connect() {
    if (this.slideTargets.length === 0) return
    this.index = 0
    this.show(this.index)

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  next() {
    const prev = this.index
    this.index = (this.index + 1) % this.slideTargets.length
    this.show(this.index)
    setTimeout(() => this.hide(prev), 1200)
  }

  show(i) { this.slideTargets[i].dataset.active = "true" }
  hide(i) { delete this.slideTargets[i].dataset.active }
}
