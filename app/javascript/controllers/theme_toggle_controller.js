import { Controller } from "@hotwired/stimulus"

/**
 * Theme Toggle Controller — page-wide colour palette switcher
 *
 * Swaps the ENTIRE page's light-section palette between two options:
 *   Option A (Cool Sage):  hero #D9D9CC, paper #DED9D1, warm #D4CFC6, bone #CBC5BA
 *   Option B (Warm Cream): hero #f7f1df, paper #fbf6e6, warm #f0e7cd, bone #ece2c4
 *
 * Works by overriding CSS custom properties on <html>, so every section
 * that references --color-eco-cream / --color-eco-paper / etc. updates instantly.
 *
 * Choice persists in localStorage across page loads.
 */
export default class extends Controller {
  static targets = ["optionA", "optionB"]

  // Two complete palettes for the light portions of the page
  static PALETTES = {
    A: {
      "--color-eco-cream":      "#D9D9CC",
      "--color-eco-paper":      "#DED9D1",
      "--color-eco-cream-warm": "#D4CFC6",
      "--color-eco-bone":       "#CBC5BA",
      "--color-eco-bg":         "#D9D9CC",
      "--color-eco-surface":    "#DED9D1",
    },
    B: {
      "--color-eco-cream":      "#f7f1df",
      "--color-eco-paper":      "#fbf6e6",
      "--color-eco-cream-warm": "#f0e7cd",
      "--color-eco-bone":       "#ece2c4",
      "--color-eco-bg":         "#f7f1df",
      "--color-eco-surface":    "#fbf6e6",
    },
  }

  connect() {
    const saved = localStorage.getItem("eco-page-theme")
    if (saved === "B") {
      this.pickB()
    } else {
      this.pickA()
    }
  }

  pickA() {
    this._apply("A")
  }

  pickB() {
    this._apply("B")
  }

  _apply(choice) {
    const palette = this.constructor.PALETTES[choice]
    const root = document.documentElement

    // Set every token on <html> so the entire page reacts
    for (const [prop, value] of Object.entries(palette)) {
      root.style.setProperty(prop, value)
    }

    // Update toggle button active states
    if (this.hasOptionATarget && this.hasOptionBTarget) {
      this.optionATarget.classList.toggle("is-active", choice === "A")
      this.optionBTarget.classList.toggle("is-active", choice === "B")
    }

    localStorage.setItem("eco-page-theme", choice)
  }
}
