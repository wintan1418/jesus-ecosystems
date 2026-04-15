import { Controller } from "@hotwired/stimulus"

// Updates --scroll-progress (0..1) on the controller element as the user
// scrolls. CSS uses the var to draw a top progress bar.
export default class extends Controller {
  connect() {
    this.handle = this.update.bind(this)
    window.addEventListener("scroll", this.handle, { passive: true })
    window.addEventListener("resize", this.handle, { passive: true })
    this.update()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handle)
    window.removeEventListener("resize", this.handle)
  }

  update() {
    const doc  = document.documentElement
    const max  = doc.scrollHeight - doc.clientHeight
    const prog = max > 0 ? Math.min(1, Math.max(0, doc.scrollTop / max)) : 0
    this.element.style.setProperty("--scroll-progress", prog)
  }
}
