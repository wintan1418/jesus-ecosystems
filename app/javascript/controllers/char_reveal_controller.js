import { Controller } from "@hotwired/stimulus"

// Splits the element's inline children into per-character spans and animates
// each in with a stagger. Preserves explicit <br> and inline elements like
// <span class="italic">. Honors prefers-reduced-motion.
export default class extends Controller {
  static values = {
    delay:    { type: Number, default: 0 },
    stagger:  { type: Number, default: 22 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.split(this.element)
    this.element.dataset.charRevealReady = "true"
  }

  split(node, baseDelay = this.delayValue) {
    const children = Array.from(node.childNodes)
    let i = 0
    children.forEach((child) => {
      if (child.nodeType === Node.TEXT_NODE) {
        const text = child.textContent
        const frag = document.createDocumentFragment()
        for (const ch of text) {
          if (ch === " ") {
            frag.appendChild(document.createTextNode(" "))
            continue
          }
          const span = document.createElement("span")
          span.className = "char-reveal-char"
          span.style.animationDelay = `${baseDelay + i * this.staggerValue}ms`
          span.textContent = ch
          frag.appendChild(span)
          i++
        }
        node.replaceChild(frag, child)
      } else if (child.nodeType === Node.ELEMENT_NODE && child.tagName !== "BR") {
        this.split(child, baseDelay + i * this.staggerValue)
      }
    })
  }
}
