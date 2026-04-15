import { Controller } from "@hotwired/stimulus"

// Tilts and offsets child [data-parallax-target="layer"] elements based on
// pointer position, with each layer using a `data-depth` attribute (0..1)
// to scale the effect. No-op on touch devices and reduced-motion users.
export default class extends Controller {
  static targets = ["layer"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    if (window.matchMedia("(hover: none)").matches) return

    this.handle = this.onMove.bind(this)
    this.element.addEventListener("pointermove", this.handle)
    this.element.addEventListener("pointerleave", () => this.reset())
  }

  disconnect() {
    if (this.handle) this.element.removeEventListener("pointermove", this.handle)
  }

  onMove(e) {
    const r = this.element.getBoundingClientRect()
    const x = (e.clientX - r.left) / r.width  - 0.5
    const y = (e.clientY - r.top)  / r.height - 0.5

    this.layerTargets.forEach((layer) => {
      const depth = parseFloat(layer.dataset.depth || "0.2")
      const tx = -x * depth * 40
      const ty = -y * depth * 40
      layer.style.transform = `translate3d(${tx}px, ${ty}px, 0)`
    })
  }

  reset() {
    this.layerTargets.forEach((l) => (l.style.transform = ""))
  }
}
