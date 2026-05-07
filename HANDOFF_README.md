# Handoff — System or Ecosystem

Seven HTML pages, one stylesheet, a few JS controllers. No build step required. Drop it on any static host and it runs.

## What you got

- `index.html` through `request-free-copy.html` — all seven pages pre-rendered from the Rails app.
- `assets/tailwind.css` — one compiled stylesheet, around 30KB gzipped. Tailwind isn't a runtime dependency here; this file is the final CSS.
- `assets/controllers/` — Stimulus controllers for the interactive bits (hero video, scroll reveals, flip book, audio player, testimonial wall).
- `assets/images/` — book covers, textures, logos.

Fonts come from Google Fonts (Playfair Display + DM Sans). Preconnect is already in every `<head>`.

## Running it

**Don't just double-click `index.html`.** If you open it directly from disk (the `file://` protocol), the page will look bare — no fonts styled right, no motion, no hero video. That's not the code being broken. Browsers deliberately block three things on `file://`:

- ES modules and importmaps (so Stimulus never boots → no scroll reveals, no flip book, no audio player, no testimonial wall)
- Absolute asset paths like `/assets/tailwind.css` (they resolve to your disk root, not the folder)
- Most cross-origin fetches

Serve it over HTTP and all of that clears up. Easiest one-liner, run it from inside the unzipped folder:

```
python3 -m http.server 8000
```

Then open `http://localhost:8000`. Any static server works — nginx, Caddy, `npx serve`, whatever you already use.

## Styles

Edit `tailwind.css` directly, or re-run Tailwind 4 against the HTML files if you prefer. Design tokens live at the top of the file as CSS custom properties: `--color-eco-green`, `--color-eco-bg`, `--color-eco-surface`, `--color-eco-text`, a handful more. Rename or repoint them and the whole site shifts.

If you're bringing this into your own design system, those variables are the seam — you shouldn't need to touch anything below them.

## Interactive behavior

Stimulus, loaded from a CDN importmap. Everything degrades gracefully — if you kill the JS, the pages still render. Content first, the JS just adds motion.

Three choices for keeping the interactive bits:

**Leave it as-is.** The importmap in each `<head>` pulls Stimulus from jsdelivr. The controllers in `assets/controllers/` auto-register. Nothing to install.

**Bundle it.** `esbuild assets/controllers/index.js --bundle --format=esm --outfile=bundle.js` and replace the importmap with a single `<script type="module" src="bundle.js">`.

**Port it.** Each controller is 20–80 lines of plain JS in a Stimulus class. Rewrite them as React hooks, Vue composables, Alpine directives, whatever your stack uses. `connect()` is mount, `disconnect()` is unmount — that's the whole API you care about.

## Stuff you'll probably swap

- **Shoutout video** on the home page sits on my Cloudinary account. Replace the URL in `index.html` with your own hosting when you migrate.
- **Hero CRT video** is an HLS stream loaded through `hls.js` from esm.sh. If you're changing the hero, you can delete that script entirely.
- **Free-copy form** (`request-free-copy.html`) has a dead `action` attribute. Point it at your backend endpoint.
- **Unsplash textures** in a couple of background spots. Replace if licensing matters for your use.

## Gotchas

- Hero is **16:9**, shoutout panel is **9:16**, book covers are **2:3**. Match these ratios when you swap media or the layout will crack.
- `loading="lazy"` matters on the book covers and shoutout poster. Don't strip it.
- Testimonial quotes on the home page are baked into the HTML here. In the original Rails build they come from a CMS setting. Either edit `index.html` directly or wire them up to your own CMS field.
- Locale is **English only**. The Rails app supports Spanish and Portuguese via URL prefix (`/es`, `/pt`), but those translations aren't finalised so they aren't in this bundle.

## Questions

Email: juwonoluwadare0@gmail.com
