import { Controller } from "@hotwired/stimulus"

// Admin Languages page: add/remove rows in the language list editor.
// Cloned rows come from a <template data-language-rows-target="template">.
export default class extends Controller {
  static targets = ["list", "template", "row"]

  add() {
    if (!this.hasTemplateTarget || !this.hasListTarget) return
    const clone = this.templateTarget.content.firstElementChild.cloneNode(true)
    this.listTarget.appendChild(clone)
    const firstInput = clone.querySelector("input")
    if (firstInput) firstInput.focus()
  }

  remove(event) {
    const row = event.target.closest("[data-language-rows-target='row']")
    if (row) row.remove()
  }
}
