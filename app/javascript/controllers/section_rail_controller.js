import { Controller } from "@hotwired/stimulus"

// Builds a vertical dot rail of the page's [data-rail-label] sections and
// highlights the active one as the user scrolls. Click a dot → smooth scroll
// to that section. Idempotent — call render() to rebuild after Turbo morphs.
export default class extends Controller {
  static targets = ["rail"]

  connect() {
    this.sections = Array.from(document.querySelectorAll("[data-rail-label]"))
    if (this.sections.length === 0) return

    this.render()
    this.observer = new IntersectionObserver(
      (entries) => this.onIntersect(entries),
      { rootMargin: "-40% 0px -55% 0px", threshold: 0 }
    )
    this.sections.forEach((s) => this.observer.observe(s))
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  render() {
    // Andrew 2026-05-18 (round 3): keep dot navigation, drop the hover labels.
    this.railTarget.innerHTML = this.sections.map((s, i) => {
      const id = s.id || `rail-section-${i}`
      if (!s.id) s.id = id
      return `
        <a href="#${id}" data-rail-dot data-section="${id}"
           class="flex items-center justify-end h-6" aria-label="${s.dataset.railLabel || id}">
          <span class="block size-1.5 rounded-full bg-eco-text-muted/40 transition-all"></span>
        </a>
      `
    }).join("")
  }

  onIntersect(entries) {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return
      const id = entry.target.id
      this.railTarget.querySelectorAll("[data-rail-dot]").forEach((dot) => {
        const active = dot.dataset.section === id
        const span = dot.querySelector("span")
        if (!span) return
        if (active) {
          span.classList.add("!size-2.5", "!bg-eco-green", "shadow-[0_0_12px_rgba(78,203,113,0.7)]")
        } else {
          span.classList.remove("!size-2.5", "!bg-eco-green", "shadow-[0_0_12px_rgba(78,203,113,0.7)]")
        }
      })
    })
  }
}
