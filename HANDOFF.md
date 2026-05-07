# System + Ecosystem — Design Handoff

This document specifies the redesign so it can be rebuilt 1:1 in the production codebase. Reference: `System + Ecosystem.html` (open it side-by-side while implementing).

---

## 1. Design tokens

```css
/* Color */
--cream:       #f7f1df;  /* primary page bg */
--paper:       #fbf6e6;  /* lightest paper bg (Hear It, Faith Rewilded, Reviews, Sprout, Footer) */
--cream-warm:  #f0e7cd;  /* card bg (cards, reviews) */
--bone:        #ece2c4;

--olive:       #8a9a68;  /* sage — stat band */
--olive-deep:  #6f7f52;  /* mid-sage — Volumes section bg */
--forest:      #4a5538;  /* deepest section bg — Manifesto */
--pull-bg:     #4a5538;  /* Pull-quote bg */
--free-bg:     #3a4530;  /* Free CTA bg (slightly darker than forest) */

--ink:         #2a2f20;  /* body text */
--ink-soft:    #5a5f4d;  /* secondary text */

--accent:      #c84634;  /* red — "They read." headline + book cover italic title */
--cta-tan:     #c9b888;  /* "Request FREE Hardcopies" button */
--cta-tan-hov: #b8a674;

--rule:        rgba(42,47,32,.14);
```

```css
/* Type */
--serif:  "Cormorant Garamond", serif;     /* display + italic emphasis */
--sans:   "Inter", system-ui, sans-serif;  /* body, nav, buttons-as-link */
--mono:   "JetBrains Mono", monospace;     /* eyebrows, meta, button labels */
--hand:   "Caveat", cursive;               /* (reserved, not currently used) */
```

```css
/* Spacing & shape */
--container-max: 1240px;
--container-pad: 56px;     /* 24px on mobile */
--radius-card:   10px;
--radius-book:   4px;
--radius-pill:   999px;
```

### Type scale (desktop)
| Use | Family | Size | Weight | Style |
|---|---|---|---|---|
| Hero H1 | serif | 78px | 500 | mixed; "to Change the World" italic |
| Section H2 (Volumes / Free) | serif | 74–78px | 500 | "Volumes." / "your hands." italic |
| Manifesto H2 | serif | 46px | 500 | with italic phrases inline |
| Hear-It H2 | serif | 64px | 500 | "from him directly." italic |
| Faith Rewilded H2 | serif | 80px | 500 | "Rewilded." italic |
| Pull quote | serif | 44px | 400 | italic phrase inline |
| Reviews H2 | serif | 60px | italic | red top line, ink bottom line |
| Card title | serif | 24px | 500 | — |
| Body | sans | 15px / 1.55 | 400 | — |
| Eyebrow / meta | mono | 10–11px | 500 | uppercase, .18–.22em tracking |

---

## 2. Section-by-section spec

The page is a single scroll. Order top → bottom:

### 2.1 Nav (sticky, `--cream` bg, 1px `--rule` bottom)
- Left: logo cluster — round mark (radial-gradient sage→deep-sage) + `System` (serif, 500) + `+ Ecosystem` (serif italic, `--ink-soft`).
- Center: `Books · Audiobooks · About · Request Free Hardcopies` (sans, 13px, `--ink-soft`). First item has 1px `--ink` underline as active state.
- Right: `EN / English ⌄` (mono 12px) + **Request FREE Hardcopies** button.
- Button: `--cta-tan` bg, `#2a2f20` text, pill, mono 11px uppercase, .16em tracking, 11×18 padding.

### 2.2 Hero (`--cream`)
Two-column grid (1.05fr / 1fr, 64px gap), 48px top / 72px bottom padding.

**Left column**
1. Eyebrow: `An Action-Toolkit For Changing The World`
2. H1, four lines: `Jesus the / Designer's Plan / to Change / the World.` — last two lines italic.
3. Lede paragraph (sans 15px, `--ink-soft`, max 430px).
4. Italic pull line: `"from mundane to mountain-movers"` (serif italic, 18px).
5. CTA row: primary tan button + ghost play link (`▶ Listen Free`, mono uppercase).

**Right column** — Hero card
- 4:3 dark rounded card (radius 14px, deep-sage bg).
- Top bar (34px, `rgba(20,24,14,.55)` blur): 3 dot dummy controls + meta text `Vol. 01 — System / Trailer` (mono uppercase, opacity .55).
- Corner tags row: `03 : 12` ··· `HD · 1080`.
- Photo placeholder (diagonal stripe pattern + bottom darken gradient). Replace with real group portrait in production.
- Centered serif italic word `System` at 84px, cream, soft shadow.
- Cream play button (46px circle, bottom-center).

### 2.3 Stats band (`--olive` sage, cream text)
- 4 columns, centered.
- Numbers: serif 54px, line-height 1. Labels: mono 10px uppercase, .22em tracking, opacity .78.
- `2 / 2 Volumes` · `3 / 3 Languages` · `100% / 100% Free · No Strings` · `360° / Faith Rewilded`. The `°` on 360 is `<sup>` at .45em.

### 2.4 Marquee (`--olive-deep`, cream text)
- Horizontal infinite scroll, 22px serif italic phrases separated by 7px cream dots (opacity .55).
- Phrases (loop these): `from struggling to legendary` · `from needy to noteworthy` · `from mundane to mountain-movers` · `from chaos to community` (×2 for seamless loop).
- 40s linear translateX(0 → -50%).

### 2.5 Manifesto (`--forest` #4a5538, cream text, centered)
- 760px max content width, 120/130 padding.
- Eyebrow: `Faith, Rewilded`.
- H2 (serif 46px, line-height 1.18): paragraph with two italicized phrases — `world-changers` and `Jesus-sized outcomes.`.
- Below, 2-col grid of 4 "point" cards: bg `rgba(247,241,223,.06)`, 1px `rgba(247,241,223,.1)` border, 10px radius. Each: bold serif italic line + plain body line.

Background texture: subtle radial sage glow at 70%/40% + faint horizontal stripe pattern (`repeating-linear-gradient(85deg, rgba(255,255,255,.02) 0 1px, transparent 1px 7px)`).

### 2.6 Hear It (`--paper`)
Two-column grid (280px / 1fr, 80px gap), 110/110 padding.

**Left** — vertical reel placeholder
- 9:16 rounded card (18px radius). Background = warm sun gradient (cream → gold → sage). Decorative leaf radial-gradient blobs. Center round portrait placeholder ringed with cream halo. Cream play FAB bottom-left.
- Below: mono caption row — `Play the message` ··· `Vertical · 0:42`.

**Right**
1. Eyebrow: `A Word From The Author`
2. H2: `Hear it / from him directly.` — second line serif italic.
3. Big serif italic open quote (`"`) in olive, 64px.
4. Pull quote (serif italic 22px, `--ink`, max 520px): `He refines ordinary people for Jesus-sized outcomes.`
5. Attribution: `— Volume One` (mono).

### 2.7 Volumes (`--olive-deep`, cream text)
- Padding 110/130. Eyebrow `02 — 2 Volumes`. H2 `The Two / Volumes.` (last line italic).
- **Grid: 2 columns, 48px gap, max-width 560px** — covers are intentionally smaller than other sections.
- Each cover wrapped in `.book-frame` which scales to `1.04` on hover (350ms ease-out).
- **No Vol I / Vol II tag, no author, no chapter/read-more meta.** Covers contain only:
  1. Top: `The` + `System` (serif 38px, line 0.95).
  2. Center: berry/leaf cluster (multi-stop radial gradients — red `#c84634`, sage `#6b8a3e`, blue `#2c6b8a`).
  3. Below center: italic `or` (serif 24px, ink-soft).
  4. Right-aligned: `The Ecosystem` (serif italic 32px, `--accent` red).
  5. Right-aligned subtitle: `Jesus the Designer's Plan / to Change the World` (serif italic 10.5px, ink-soft).
- Cover bg: vol1 = `--cream` (#f7f1df), vol2 = `#ece3c7` (slightly warmer/darker).
- Aspect ratio 3 : 4.4. Box-shadow `0 24px 48px -22px rgba(0,0,0,.4)`.
- **Replace berry SVG with real cover artwork in production.**

### 2.8 Faith, Rewilded (`--paper`, centered)
- Eyebrow `06 — Faith Rewilded`. H2 `Faith, / Rewilded.` (italic line 2).
- 4-column grid (18px gap), each card:
  - 5:4 image (linear gradient placeholder per card — sage / amber / oxblood / steel-blue). Replace with real photography.
  - Mono caption inside image bottom-left: `01 / Roots`, `02 / Canopy`, `03 / Order`, `04 / Air`.
  - Title (serif 24px) + 1-line description.
- Card hover: translateY(-4px) + 0 20 40 -20 shadow.

| # | Title | Description |
|---|---|---|
| 1 | Living Roots | Down to the original text — not free-text editing. |
| 2 | Open Canopy | Light cuts through where structure is symbolic. |
| 3 | Wild Order | There is deep, intentional intent. |
| 4 | Mutual Air | What we breathe in, and breathe out is. |

### 2.9 Pull quote (`--pull-bg` #4a5538, cream)
- Centered. Big italic 80px open quote (opacity .45).
- H2 (serif 44px, max 800px): `Religion is typically about a club, a vibe, and rules — Jesus came to blow that up.` (italic phrase after the em dash).
- Source line: mono uppercase `From Volume One`.

### 2.10 Reviews — "They read. Then they wrote back." (`--paper`)
- Eyebrow `What Readers Are Saying`.
- H2 stacked: line 1 `They read.` in `--accent` red italic; line 2 `Then they wrote back.` in `--ink` italic.
- 4-column grid (14px gap) of testimonial cards (`--cream-warm` bg, 8px radius, 18px pad).
  - Body: 12.5px sans, ink-soft.
  - Footer: mono uppercase name `· City` (city in ink-soft 400).
- Below the grid, centered mono row of locations separated by `/` — Lagos / Berea / Lekki / Ibadan / Yaba / Online.

### 2.11 Free CTA (`--free-bg` #3a4530, cream, centered)
- Eyebrow `100% Free · No Strings`.
- H2 (serif 78px): `Get the books, free, in / your hands.` (last 2 words italic).
- Sub-line (mono): `100% free hardcopies. Worldwide shipping. No strings.`.
- CTA: outline cream pill button `Request FREE Hardcopies`.
- Background composition: dark sage base + subtle horizon glow at 50% 100% + faint vertical stripe.

### 2.12 Sprout outro (`--paper`, centered)
- 48px sprout SVG (stem + 2 leaves, sage tones).
- Mono label below: `Faith, Rewilded`.
- Behind it, an oversized italic serif word `Ecosystem` at 240px in `rgba(28,31,21,.05)` overflowing the bottom — pure decoration.

### 2.13 Footer (`--paper`, top 1px `--rule`)
- 4-col grid (1.5fr/1fr/1fr/1fr).
- Col 1: brand mark + `System + Ecosystem` lockup; serif italic blurb `Jesus the Designer's Plan to change the world, kept in your hands — free.`
- Col 2 — **Read**: Books / Audiobooks.
- Col 3 — **More**: About / Contact / Request Free Hardcopies.
- Col 4 — **Languages**: EN — English / FR — Français / ES — Español.
- Bottom legal row (mono 10px uppercase): `© 2026 System + Ecosystem · All rights reserved.` ··· `Crafted with care · Faith, Rewilded`.

---

## 3. Right-edge section labels
Every section has a vertical mono label pinned to the right edge (`writing-mode: vertical-rl; rotate(180deg)`), index-numbered 01 through 11. On dark sections add the `light` class so it switches to cream.

---

## 4. Interaction notes

| Element | Behavior |
|---|---|
| Volume covers | Whole frame scales to 1.04 on hover, 350ms cubic-bezier(.2,.7,.2,1). No per-element zoom. |
| Faith Rewilded cards | translateY(-4px) + soft shadow on hover. |
| Marquee | Infinite horizontal scroll, 40s, paused never. Duplicate phrase set so wrap is seamless. |
| Buttons | Background swap on hover; tan CTA → darker tan, cream outline → cream-fill. |
| Nav | Sticky, no scroll-blur. First nav link is "active" state (1px ink underline). |

---

## 5. Assets the design needs (placeholders right now)

| Slot | What to drop in |
|---|---|
| Hero card photo | Real group portrait, 4:3, dark/cinematic. |
| Hear-It reel | Vertical 9:16 video thumbnail of author with leafy frame. |
| Volume 1 cover | Production cover artwork (replace berry gradient). |
| Volume 2 cover | Production cover artwork. |
| Faith Rewilded × 4 | Real photography matching pillar (roots / canopy / order / air). |
| Sprout SVG | OK as-is; replace if brand has its own mark. |

---

## 6. Responsive
Below 960px, all multi-column grids collapse to 1fr, hero card becomes 16:10, nav links hide (replace with hamburger), stats band becomes 2×2, all section H2s drop to 32–48px.

---

## 7. Accessibility
- All eyebrows, marquee, and decorative quote marks: `aria-hidden="true"` where they don't add information.
- Hero play link, reel play FAB, and corner play FAB all need real `<button>` semantics with `aria-label="Play [title]"` in production.
- Color contrast: ink (#2a2f20) on cream (#f7f1df) = AAA. Cream on forest (#4a5538) = AA. Tan CTA text uses ink, not cream.

---

## 8. Things deliberately removed from the previous version
1. Vol. I / Vol. II tag over each cover.
2. Author name on each cover.
3. Chapter / Read More meta strip beneath each cover.
4. Aggressive cover-only zoom on hover (replaced with whole-frame 4% scale).
5. Forest-black backgrounds — switched to lighter sage / forest-sage palette throughout.
