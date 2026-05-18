import { Controller } from "@hotwired/stimulus"

// Andrew 2026-05-18: thumbnail is 16:9 horizontal, video plays vertical (9:16)
// inside a centered <dialog> lightbox. Click backdrop or ESC closes; in both
// cases we pause the video so it doesn't keep playing offscreen.
export default class extends Controller {
  static targets = ["dialog", "video"]

  open(event) {
    if (event) event.preventDefault()
    if (!this.hasDialogTarget || !this.hasVideoTarget) return

    this.dialogTarget.showModal()
    document.body.style.overflow = "hidden"
    this.videoTarget.currentTime = 0

    const p = this.videoTarget.play()
    if (p && typeof p.catch === "function") {
      p.catch(() => {
        this.videoTarget.muted = true
        this.videoTarget.play().catch(() => {})
      })
    }
  }

  close() {
    if (!this.hasDialogTarget) return
    if (this.hasVideoTarget) this.videoTarget.pause()
    if (this.dialogTarget.open) this.dialogTarget.close()
    document.body.style.overflow = ""
  }

  // The <dialog> backdrop fires click on the dialog itself. Clicks inside the
  // inner frame bubble up with target inside the frame, so we filter on target.
  backdropClose(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  connect() {
    this.handleCancel = () => {
      if (this.hasVideoTarget) this.videoTarget.pause()
      document.body.style.overflow = ""
    }
    if (this.hasDialogTarget) {
      this.dialogTarget.addEventListener("cancel", this.handleCancel)
    }
  }

  disconnect() {
    if (this.hasDialogTarget && this.handleCancel) {
      this.dialogTarget.removeEventListener("cancel", this.handleCancel)
    }
    document.body.style.overflow = ""
  }
}
