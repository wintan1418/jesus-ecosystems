import { Controller } from "@hotwired/stimulus"

// Swaps the shoutout poster/play-button for the actual <video> on click.
// Why: the banner image is 16:9 horizontal but the video is 9:16 vertical;
// using <video poster> directly warps the image, so we layer a real <img>
// with object-fit: cover and reveal the video when the user opts in.
export default class extends Controller {
  static targets = ["trigger", "poster", "badge", "video"]

  start(event) {
    if (event) event.preventDefault()
    if (this.started) return
    this.started = true

    // Fade the poster + badge; swap video in with native controls.
    this.posterTarget.dataset.hidden = "true"
    this.badgeTarget.dataset.hidden  = "true"
    this.videoTarget.controls        = true
    this.videoTarget.dataset.active  = "true"

    // Trigger playback
    this.videoTarget.play().catch(() => {
      // Autoplay with sound is often blocked — fall back to muted autoplay
      // so the user at least sees motion; they can unmute via native controls.
      this.videoTarget.muted = true
      this.videoTarget.play().catch(() => {})
    })

    // Once playback ends, restore the poster so replay is obvious.
    this.videoTarget.addEventListener("ended", () => this.reset(), { once: true })
  }

  reset() {
    this.started = false
    this.videoTarget.controls = false
    delete this.videoTarget.dataset.active
    delete this.posterTarget.dataset.hidden
    delete this.badgeTarget.dataset.hidden
    this.videoTarget.currentTime = 0
  }
}
