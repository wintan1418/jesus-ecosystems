import { Controller } from "@hotwired/stimulus"

// Splits the element's inline children into per-character spans and animates
// each in with a stagger. Each word is wrapped in an outer nowrap span so
// Safari can't orphan a single inline-block character onto its own line —
// that was causing "Change" to render as "Chang / e" on iPhone. Preserves
// explicit <br> and inline elements like <span class="italic">. Honors
// prefers-reduced-motion.
export default class extends Controller {
  static values = {
    delay:   { type: Number, default: 0 },
    stagger: { type: Number, default: 22 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.counter = 0
    this.split(this.element)
    this.element.dataset.charRevealReady = "true"
  }

  split(node) {
    const children = Array.from(node.childNodes)
    children.forEach((child) => {
      if (child.nodeType === Node.TEXT_NODE) {
        node.replaceChild(this.buildFragment(child.textContent), child)
      } else if (child.nodeType === Node.ELEMENT_NODE && child.tagName !== "BR") {
        this.split(child)
      }
    })
  }

  // Split text on whitespace, keep the whitespace nodes, and wrap each real
  // word in a nowrap span containing per-character spans. Safari will no
  // longer break individual characters across lines.
  buildFragment(text) {
    const frag = document.createDocumentFragment()
    const parts = text.split(/(\s+)/)

    for (const part of parts) {
      if (part.length === 0) continue
      if (/^\s+$/.test(part)) {
        frag.appendChild(document.createTextNode(part))
        continue
      }

      const wordSpan = document.createElement("span")
      wordSpan.className = "char-reveal-word"
      for (const ch of part) {
        const span = document.createElement("span")
        span.className = "char-reveal-char"
        span.style.animationDelay = `${this.delayValue + this.counter * this.staggerValue}ms`
        span.textContent = ch
        wordSpan.appendChild(span)
        this.counter++
      }
      frag.appendChild(wordSpan)
    }
    return frag
  }
}
