import { Controller } from "@hotwired/stimulus"

// Generic modal: click the controller root's [data-action="click->modal#open"]
// to open, click backdrop / close button / press Escape to close. The modal
// body lives in a [data-modal-target="panel"] element that starts hidden.
//
// If a [data-modal-target="video"] <video> element is inside, it's paused
// and rewound on close so the vertical shoutout doesn't keep playing behind
// the scenes.
export default class extends Controller {
  static targets = ["panel", "video"]

  connect() {
    this.onKey = this.onKey.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKey)
  }

  open(event) {
    if (event) event.preventDefault()
    this.panelTarget.dataset.open = "true"
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.onKey)

    if (this.hasVideoTarget) {
      const v = this.videoTarget
      const src = v.dataset.src
      if (src && !v.src) v.src = src
      v.currentTime = 0
      v.play().catch(() => {})
    }
  }

  close(event) {
    if (event) event.preventDefault()
    delete this.panelTarget.dataset.open
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.onKey)

    if (this.hasVideoTarget) {
      this.videoTarget.pause()
      this.videoTarget.currentTime = 0
    }
  }

  // Close on backdrop click but not when clicking the inner content
  backdrop(event) {
    if (event.target === this.panelTarget || event.target.dataset.modalBackdrop) {
      this.close(event)
    }
  }

  onKey(e) {
    if (e.key === "Escape") this.close()
  }
}
