import { Controller } from "@hotwired/stimulus"

// Subtly leans the element toward the cursor when within `radius` px of its
// center. Keeps the lean small (max ~8px) so it reads as a luxury "responds
// to you" effect, not a gimmick. No-op on touch + reduced-motion.
export default class extends Controller {
  static values = {
    radius:   { type: Number, default: 80 },
    strength: { type: Number, default: 0.22 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    if (window.matchMedia("(hover: none)").matches) return

    this.element.style.transition =
      "transform 0.45s cubic-bezier(0.2, 0.7, 0.2, 1)"
    this.handleMove  = this.onMove.bind(this)
    this.handleLeave = this.onLeave.bind(this)
    window.addEventListener("pointermove", this.handleMove, { passive: true })
    this.element.addEventListener("pointerleave", this.handleLeave)
  }

  disconnect() {
    window.removeEventListener("pointermove", this.handleMove)
    this.element.removeEventListener("pointerleave", this.handleLeave)
    this.element.style.transform = ""
  }

  onMove(e) {
    const r  = this.element.getBoundingClientRect()
    const cx = r.left + r.width  / 2
    const cy = r.top  + r.height / 2
    const dx = e.clientX - cx
    const dy = e.clientY - cy
    const dist = Math.hypot(dx, dy)

    if (dist > this.radiusValue + Math.max(r.width, r.height) / 2) {
      this.element.style.transform = ""
      return
    }

    const tx = dx * this.strengthValue
    const ty = dy * this.strengthValue
    this.element.style.transform = `translate3d(${tx}px, ${ty}px, 0)`
  }

  onLeave() {
    this.element.style.transform = ""
  }
}
