import { Controller } from "@hotwired/stimulus"

// Sets a CSS variable on the root with the pointer position so any
// element styled with [data-cursor-spotlight-bg] can render a radial
// gradient that follows the cursor. Cheaper than positioning a real DOM
// element and avoids layout thrash. Skips on touch and reduced-motion.
export default class extends Controller {
  connect() {
    if (window.matchMedia("(hover: none)").matches) return
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.handle = this.onMove.bind(this)
    window.addEventListener("pointermove", this.handle, { passive: true })
    document.documentElement.dataset.cursorSpotlight = "on"
  }

  disconnect() {
    if (this.handle) window.removeEventListener("pointermove", this.handle)
    delete document.documentElement.dataset.cursorSpotlight
  }

  onMove(e) {
    const root = document.documentElement
    root.style.setProperty("--cursor-x", e.clientX + "px")
    root.style.setProperty("--cursor-y", e.clientY + "px")
  }
}
