import { Controller } from "@hotwired/stimulus"

// Marks the controller element with [data-plant-grown="true"] when it scrolls
// into view, which kicks off the SVG stroke-draw animations defined in CSS.
export default class extends Controller {
  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.dataset.plantGrown = "true"
      return
    }

    this.observer = new IntersectionObserver(
      (entries, obs) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.element.dataset.plantGrown = "true"
            obs.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.3 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
