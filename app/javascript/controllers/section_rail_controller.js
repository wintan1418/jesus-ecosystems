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
    this.railTarget.innerHTML = this.sections.map((s, i) => {
      const label = s.dataset.railLabel
      const id = s.id || `rail-section-${i}`
      if (!s.id) s.id = id
      return `
        <a href="#${id}" data-rail-dot data-section="${id}"
           class="group flex items-center gap-3 justify-end h-6">
          <span class="text-[10px] tracking-[0.3em] uppercase text-eco-text-muted opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all">${label}</span>
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
        const span = dot.querySelector("span:last-child")
        const label = dot.querySelector("span:first-child")
        if (active) {
          span.classList.add("!size-2.5", "!bg-eco-green", "shadow-[0_0_12px_rgba(78,203,113,0.7)]")
          label.classList.add("!opacity-100", "!translate-x-0", "!text-eco-green-light")
        } else {
          span.classList.remove("!size-2.5", "!bg-eco-green", "shadow-[0_0_12px_rgba(78,203,113,0.7)]")
          label.classList.remove("!opacity-100", "!translate-x-0", "!text-eco-green-light")
        }
      })
    })
  }
}
