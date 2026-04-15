import { Controller } from "@hotwired/stimulus"

// 3D flip-book reader.
//
// Markup model:
//   <div data-controller="flip-book">
//     <div data-flip-book-target="book">
//       <div data-flip-book-target="leaf"> ... </div>  ← repeats
//     </div>
//     <button data-action="flip-book#prev">←</button>
//     <button data-action="flip-book#next">→</button>
//     <span data-flip-book-target="counter"></span>
//   </div>
//
// State: `index` is the number of leaves that have been flipped (0..N).
// Each leaf is the right page until flipped, then becomes the left page.
// The leaf's transform-origin is its left edge so it pivots around the spine.
// We manage z-index so unflipped leaves stack right-to-front, flipped leaves
// left-to-back, which keeps the visible spread correct.
export default class extends Controller {
  static targets = ["book", "leaf", "counter", "prev", "next"]
  static values  = { index: { type: Number, default: 0 } }

  connect() {
    this.applyZIndexes()
    this.updateChrome()
    this.handleKey = this.onKey.bind(this)
    document.addEventListener("keydown", this.handleKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKey)
  }

  next(event) {
    if (event) event.preventDefault()
    if (this.indexValue >= this.leafTargets.length) return
    const leaf = this.leafTargets[this.indexValue]
    leaf.dataset.flipped = "true"
    this.indexValue += 1
    this.applyZIndexes()
    this.updateChrome()
  }

  prev(event) {
    if (event) event.preventDefault()
    if (this.indexValue <= 0) return
    this.indexValue -= 1
    const leaf = this.leafTargets[this.indexValue]
    delete leaf.dataset.flipped
    this.applyZIndexes()
    this.updateChrome()
  }

  // Leaves before the current index are flipped — they should sit at the BOTTOM
  // of the left stack (small z-index). Leaves at or after the current index are
  // unflipped — they should sit at the TOP of the right stack (small index = top).
  applyZIndexes() {
    const total = this.leafTargets.length
    this.leafTargets.forEach((leaf, i) => {
      if (i < this.indexValue) {
        // Flipped leaves: bottom-of-stack on the left side
        leaf.style.zIndex = i + 1
      } else {
        // Unflipped leaves: descending so leaf[currentIndex] is on top of right stack
        leaf.style.zIndex = total + (total - i)
      }
    })
  }

  updateChrome() {
    if (this.hasCounterTarget) {
      const total = this.leafTargets.length
      this.counterTarget.textContent = `${this.indexValue} / ${total}`
    }
    if (this.hasPrevTarget) this.prevTarget.disabled = this.indexValue === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.indexValue === this.leafTargets.length
  }

  onKey(e) {
    if (e.target && ["INPUT", "TEXTAREA"].includes(e.target.tagName)) return
    if (e.key === "ArrowRight" || e.key === " ") { e.preventDefault(); this.next() }
    if (e.key === "ArrowLeft")  { e.preventDefault(); this.prev() }
  }
}
