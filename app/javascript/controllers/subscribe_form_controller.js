import { Controller } from "@hotwired/stimulus"

// Disables the submit button + updates the label to "Subscribing…" while
// the Turbo Frame request is in flight. Resets after the frame swap.
export default class extends Controller {
  connect() {
    this.element.addEventListener("submit", this.onSubmit.bind(this))
  }

  onSubmit() {
    const btn = this.element.querySelector("[type='submit']")
    if (!btn) return
    btn.disabled = true
    btn.dataset.originalValue ||= btn.value
    btn.value = "Subscribing…"
  }
}
