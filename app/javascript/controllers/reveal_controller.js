import { Controller } from "@hotwired/stimulus"

// Adds [data-revealed] when the element scrolls into view, allowing CSS to
// animate it in. Uses IntersectionObserver and unobserves after the first
// reveal so it stays performant even with many elements.
export default class extends Controller {
  static values = { threshold: { type: Number, default: 0.15 } }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.dataset.revealed = "true"
      return
    }

    this.observer = new IntersectionObserver(
      (entries, obs) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.dataset.revealed = "true"
            obs.unobserve(entry.target)
          }
        })
      },
      { threshold: this.thresholdValue, rootMargin: "0px 0px -10% 0px" }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
