# CLAUDE.md — SystemOrEcosystem Rails 8 Rebuild

> **Source of truth:** `systemorecosystem_rails_brief.docx` (v1.0). This file is the distilled, always-loaded working agreement for Claude Code. When the brief and this file disagree, the brief wins — update this file to reconcile.

---

## 1. Mission

Rebuild **systemorecosystem.com** as a production-grade, multilingual, content-first platform for the two-volume Christian **action toolkit** *The System or The Ecosystem*. The current site is flat and static; this rebuild must feel like a **living editorial journal meets a faith movement** — dark, organic, deliberate, alive.

> **Language rule:** the books are **not** "philosophy." Never describe them as philosophy, a philosophy series, or a philosophical work. Always use **"action toolkit"** or a near synonym (field guide, playbook, practical handbook). The designer was explicit about this on 2026-04-16.

**Primary jobs of the site:**
1. Present the two books (Vol 1, Vol 2) with depth, excerpts, and preview chapters.
2. Let visitors **listen** to audiobooks in EN / ES / PT.
3. Let visitors **request a free physical hardcopy** via a multi-step form.
4. Capture email subscribers for future releases.
5. Give the admin full CMS control without deployments.

**Audiences:** Visitor (first-time / faith-curious), Reader (returning), Admin (owner).

---

## 2. Stack & Versions

| Layer | Choice | Notes |
|---|---|---|
| Framework | **Rails 8.1.x** | Already installed in this repo |
| Ruby | **3.3+** | Pin in `.ruby-version` |
| Frontend | **Hotwire** — Turbo + Stimulus | No React, no Vue, no SPA frameworks |
| CSS | **Tailwind CSS 4** via `tailwindcss-rails` | See §9 for design tokens |
| JS pipeline | **Importmap** (target) | ⚠️ See §3 — currently jsbundling |
| Database | **PostgreSQL** | |
| Jobs / Cache / Cable | **Solid Queue / Solid Cache / Solid Cable** | Rails 8 defaults, keep them |
| Storage | **Active Storage + Cloudflare R2** | WebP variants via `image_processing` |
| Auth (admin only) | **Devise** | No public registration ever |
| Authorization | **Pundit** | Policy specs required |
| Admin UI | **Avo** (preferred) or ActiveAdmin | Avo for the modern Rails 8 feel |
| Slugs | **friendly_id** | Locale-scoped |
| i18n | **rails-i18n** + per-locale YAMLs | Day-one discipline |
| Email | **Resend** (via SMTP) | Postmark acceptable fallback |
| Analytics | **ahoy_matey** | Privacy-first, no third-party JS |
| Notifications | **noticed** | Admin bell on new free-copy requests |
| Meta / SEO | **meta-tags** + `sitemap_generator` | Hreflang + JSON-LD mandatory |
| Testing | **RSpec + FactoryBot + Capybara + Playwright** | ⚠️ See §3 — currently Minitest |
| Deploy | **Kamal 2** or Hatchbox | Zero-downtime |
| CDN / DNS | Cloudflare | TLS terminated there |
| Errors | Sentry (free) | |
| Uptime | Better Uptime (free) | |

---

## 3. Known Scaffold Deltas (fix in Phase 1)

The `rails new` in this repo was generated with the **default** flags, which do not match the brief. Phase 1 must reconcile:

| Area | Current | Target | Action |
|---|---|---|---|
| JS bundling | `jsbundling-rails` | **Importmap** | Remove `jsbundling-rails`, add `importmap-rails`, run `bin/rails importmap:install` |
| CSS bundling | `cssbundling-rails` | **`tailwindcss-rails` (Tailwind 4)** | Remove `cssbundling-rails`, add `tailwindcss-rails`, run `bin/rails tailwindcss:install` |
| Test framework | Minitest (`test/`) | **RSpec** | Add `rspec-rails`, `factory_bot_rails`; run `bin/rails g rspec:install`; delete `test/` |
| System tests | Selenium | **Playwright** | Configure `capybara-playwright-driver` |
| Procfile.dev | `yarn build` / `yarn build:css` | `bin/rails tailwindcss:watch` only | Update once importmap/tailwind land |

Do not attempt phases 2+ until §3 is green.

---

## 4. Domain Model (canonical)

All columns are listed in the brief §3. Summary of the eight tables:

- **books** — canonical volumes (title, volume_number, slug, description, tagline, cover_image, published_at, position).
- **book_translations** — per-locale edition (book_id, locale, title, description, tagline, slug).
- **chapters** — ActionText body, `is_preview` flag for public visibility, locale, position per book.
- **audiobooks** — per-locale audio file on R2, duration_seconds, position.
- **free_copy_requests** — full shipping address, `volumes_requested` array, enum `status` (pending / fulfilling / shipped / cancelled), locale, notes, ip_address.
- **email_subscribers** — email (unique), first_name, locale, source, `confirmed_at` (double opt-in), `unsubscribed_at`.
- **site_settings** — key/value store for hero text, banners, social links (no deploys for copy tweaks).
- **admins** — Devise-backed; admin-only login.

**Rules:**
- All public-facing copy belongs in either `book_translations`, `chapters` (locale-scoped), or `site_settings` — **never hardcoded in views**.
- Free-copy requests are the most sensitive data in the system. Treat them as PII: never log bodies, never expose via JSON endpoints.
- `volumes_requested` is a Postgres array of strings (`'1'`, `'2'`) — validate membership at the model level.

---

## 5. Routing Contract

```ruby
scope '(:locale)', locale: /en|es|pt/ do
  root 'pages#home'
  resources :books, only: [:index, :show], param: :slug do
    resources :chapters, only: [:show], param: :slug
  end
  resources :audiobooks, only: [:index, :show]
  resources :free_copy_requests, only: [:new, :create]
  get '/request-free-copy',            to: 'free_copy_requests#new'
  get '/request-free-copy/thank-you',  to: 'free_copy_requests#thank_you'
  get '/about',   to: 'pages#about'
  get '/contact', to: 'pages#contact'
end

devise_for :admins
namespace :admin do
  root 'dashboard#index'
  resources :books, :chapters, :audiobooks,
            :free_copy_requests, :email_subscribers, :site_settings
end
```

**Locale rules:**
- URL prefix is the source of truth: `/en/`, `/es/`, `/pt/`. Default is `en`, accessible at root without prefix.
- Persist last-seen locale in a cookie, not a session, so it survives.
- **Every** `link_to` / `url_for` must pass `locale:` or rely on `default_url_options` — never hardcode.

---

## 6. Controllers (inventory)

| Controller | Actions | Responsibility |
|---|---|---|
| `PagesController` | `#home`, `#about`, `#contact` | Static / semi-dynamic — copy from `site_settings` |
| `BooksController` | `#index`, `#show` | Volume listing + detail |
| `ChaptersController` | `#show` | Single chapter reader, gated by `is_preview` |
| `AudiobooksController` | `#index`, `#show` | Streams audio via Active Storage URL |
| `FreeCopyRequestsController` | `#new`, `#create`, `#thank_you` | Multi-step Turbo Frame form |
| `Admin::DashboardController` | `#index` | KPIs: requests, subscribers, visitors |
| `Admin::*Controller` | Full CRUD (via Avo) | Book/Chapter/Audiobook/Request/Subscriber mgmt |

---

## 7. Feature Acceptance Criteria

### 7.1 Homepage (`/`)
- Full-viewport hero: book title, tagline, dual CTA ("Explore the Books" + "Listen Free").
- Two-column layout: manifesto copy (left, animated text reveal via Stimulus) / book cards (right).
- Stats bar: `2 Volumes · 3 Languages · Free copies available`.
- Four-pillar "Faith Rewilded" section — content editable via `site_settings`.
- Large pull-quote band with attribution.
- Language switcher pills (EN / ES / PT) with active state.
- Free-copy CTA section with "100% Free · No strings" badge.
- Footer: nav, copyright, social links (from `site_settings`).

### 7.2 Book detail (`/books/:slug`)
- Cover image (WebP variant), title, volume badge.
- Expandable chapter list — only `is_preview: true` rows visible to anonymous visitors.
- Prominent "Get Free Hardcopy" CTA.
- Audiobook card linking to `/audiobooks/:id`.
- Breadcrumbs: Home > Books > Volume N.

### 7.3 Audiobook page (`/audiobooks`)
- Custom HTML5 `<audio>` player driven by a Stimulus controller (not a gem).
- Track list: volume, locale, duration.
- Progress persisted to `localStorage`.
- Turbo Frame swap for player updates — no full reload on track change.

### 7.4 Free-copy request form (`/request-free-copy`)
- Three Turbo Frame steps: (1) Name + Email, (2) Shipping address, (3) Volume selection + review.
- Server-side validation; inline errors via Turbo Streams.
- Spam defenses: honeypot field + `rack-attack` IP rate limiting.
- On success: redirect to `/request-free-copy/thank-you`, queue confirmation email to requestor, queue admin notification (`noticed`), broadcast dashboard update.
- Thank-you page has Twitter/X and WhatsApp share deep links.

### 7.5 Language switching
- Pills in nav **and** footer.
- Uses Turbo visit for smooth feel.
- All UI strings live in `config/locales/{en,es,pt}.yml` — zero tolerance for raw English in views.
- `friendly_id` produces locale-scoped slugs so SEO is clean per language.

### 7.6 Admin panel
- Dashboard: today's new requests, total subscribers, recent visitors (from Ahoy).
- Free-copy requests: filter by status / country / locale, bulk status update.
- Books: ActionText editor for chapters, drag-to-reorder via `acts_as_list`.
- Email subscribers: CSV export, source breakdown.
- Site settings: key/value editor — avoid redeploying for copy changes.

---

## 8. Design System

### 8.1 Aesthetic direction
**Dark organic luxury.** Forest-deep greens, warm off-whites, editorial serif display. Think premium literary journal × faith movement. Avoid stock SaaS gradients, glass-morphism, neon. Motion should feel **botanical**: slow, eased, purposeful.

### 8.2 Colour tokens (`tailwind.config.js`)

| Token | Hex / rgba | Usage |
|---|---|---|
| `eco-bg` | `#0d1a12` | Page background |
| `eco-surface` | `#142019` | Cards, panels |
| `eco-border` | `rgba(255,255,255,0.08)` | Dividers |
| `eco-green` | `#4ecb71` | Primary accent, CTAs, links |
| `eco-green-light` | `#b8e8c4` | Secondary accents |
| `eco-green-muted` | `rgba(78,203,113,0.10)` | Hover fills |
| `eco-text` | `#e8ede9` | Body text |
| `eco-text-muted` | `rgba(232,237,233,0.55)` | Secondary text |
| `eco-white` | `#f5faf6` | Headings |

### 8.3 Typography

| Role | Font | Weight |
|---|---|---|
| Display / headings | **Playfair Display** | 700, 400 italic |
| Body / UI | **DM Sans** | 300 / 400 / 500 |
| Eyebrow labels | DM Sans | 500, `0.2em` tracking, uppercase |
| Admin mono | JetBrains Mono | 400 |

Load via `<link rel="preconnect">` + `<link>` to `fonts.googleapis.com`, Latin subset only.

### 8.4 Components (ViewComponent + Stimulus)
- `AudioPlayerComponent`
- `BookCardComponent`
- `LanguageSwitcherComponent`
- `FreeCopyFormComponent`
- `PullQuoteComponent`
- `AdminStatusBadgeComponent`

Every reusable piece of UI goes into a ViewComponent with its own preview and spec. No one-off partials for anything shown on more than one page.

---

## 9. Email

All transactional email through **Resend** SMTP. Mailers live in `app/mailers/`.

| Mailer | Trigger | Recipient |
|---|---|---|
| `FreeCopyMailer#confirmation` | `FreeCopyRequest#create` | Requestor |
| `AdminMailer#new_request` | `FreeCopyRequest#create` | `ENV['ADMIN_EMAIL']` |
| `FreeCopyMailer#status_update` | Admin sets status = `shipped` | Requestor |
| `SubscriberMailer#confirm` | Newsletter signup | Subscriber |
| `SubscriberMailer#welcome` | After double opt-in | Subscriber |

Every mailer is i18n-aware: `mail(subject: t('...'))`, templates per locale.

---

## 10. SEO & Performance

- `meta-tags` in every controller: title, description, `og:*`, `twitter:*`, `og:image`.
- **Hreflang** tags for all three locales in `<head>` — non-negotiable for multilingual ranking.
- `sitemap_generator`: per-locale sitemap; GitHub Actions pings Google on deploy.
- JSON-LD on home (`Organization`) and book pages (`Book`).
- Canonical tags on every page.
- Turbo Drive for SPA feel.
- Fragment caching on book cards and chapter lists, keyed by `[book, locale, updated_at]`.
- R2-backed Active Storage with WebP variants, `loading="lazy"` + IntersectionObserver Stimulus controller.
- Target: **Lighthouse ≥ 90** mobile + desktop before launch.

---

## 11. Testing

| Type | Tool | Target |
|---|---|---|
| Models | RSpec + FactoryBot | Validations, scopes, associations — 100% |
| Mailers | RSpec | All mailer methods |
| Jobs | RSpec | All background jobs |
| Requests | RSpec request specs | Every route, status code, redirect |
| Turbo | RSpec + Capybara | Form submissions, Turbo Stream responses |
| System / E2E | Capybara + Playwright | Free-copy flow, language switch, audio player |
| Auth | Pundit policy specs | All admin actions blocked for visitors |

**Rules:**
- No new controller action ships without a request spec.
- Free-copy flow is covered by a full system test before Phase 3 closes.
- Run `bundle exec rspec` and `bundle exec brakeman` before every push.

---

## 12. Deployment & Env Vars

Production stack: Kamal 2 (or Hatchbox) → Puma → PostgreSQL (managed) → Cloudflare R2 → Cloudflare CDN → Sentry → Better Uptime → GitHub Actions CI.

Required env vars (via Rails credentials or Kamal secrets — **never commit**):

```
RAILS_MASTER_KEY=
DATABASE_URL=
RESEND_API_KEY=
CLOUDFLARE_R2_BUCKET=systemorecosystem
CLOUDFLARE_R2_ACCESS_KEY_ID=
CLOUDFLARE_R2_SECRET_ACCESS_KEY=
CLOUDFLARE_R2_ENDPOINT=
SENTRY_DSN=
ADMIN_EMAIL=
```

---

## 13. Phased Build Plan

Each phase is a **deployable milestone**. Deploy at the end of every phase.

- **Phase 1 — Foundation (Week 1–2)** — Reconcile scaffold deltas (§3), Tailwind + importmap, Devise admin, all migrations, R2 storage, application layout shell, i18n skeleton. Deploy.
- **Phase 2 — Core Content (Week 3–4)** — Homepage, books index/show, audiobooks page, i18n routing, language switcher, meta-tags + friendly_id. Deploy.
- **Phase 3 — Free Copy Flow (Week 5)** — Multi-step Turbo Frame form, Resend mailers, rack-attack + honeypot, thank-you page. Deploy.
- **Phase 4 — Admin Panel (Week 6)** — Avo resources, dashboard, noticed notifications, CSV exports. Deploy.
- **Phase 5 — Polish & Launch (Week 7–8)** — Sitemap, JSON-LD, Ahoy, fragment caching, full RSpec green, Lighthouse ≥ 90, DNS cutover. Ship.

Do not jump ahead of the current phase without the user's consent.

---

## 14. Conventions (the short list)

### Do
- Use Rails 8 defaults (Solid Queue/Cache/Cable, importmap, Tailwind).
- Use Hotwire Turbo for **all** form submissions and partial updates.
- Use Tailwind utility classes with the `eco-*` tokens — no custom CSS files unless a utility literally cannot express it.
- Write RSpec for every model and controller action as you build them, not after.
- Put every user-facing string behind `t('…')` from day one.
- Follow RESTful routing strictly. Sub-resources for things that are truly sub-resources.
- Use ViewComponent for any UI that repeats.
- Use `friendly_id` for all slugs.

### Do NOT
- Do not add Webpack, esbuild, rollup, Node build pipelines, or re-introduce `jsbundling-rails` / `cssbundling-rails`.
- Do not add authentication for public visitors. Only admins log in.
- Do not hardcode English copy in views — i18n from day one.
- Do not write custom CSS when a Tailwind utility exists.
- Do not bypass RESTful conventions without stating the reason in a commit.
- Do not introduce React, Vue, Svelte, or any SPA framework. Stimulus only.
- Do not make architectural decisions that aren't covered in this file or the brief — **ask first**.
- Do not add `Co-Authored-By: Claude` trailers on commits. Do not sign authored files with Claude attribution.

---

## 15. Working with Claude on this repo

- **Start of a new session:** read this file and `systemorecosystem_rails_brief.docx` before coding.
- **Phase prompts:** the brief §12.2 has focused prompts for Phases 2–5. Use them verbatim when starting a phase.
- **Debugging:** when you need help, paste the error + stack trace + the relevant model/controller + `Gemfile.lock` row if gem-related.
- **UI questions:** describe the Tailwind classes in play and the expected vs actual rendering.
- **Commits:** small, phase-scoped, imperative mood, no Claude co-author trailer.
- **Before merging:** `bundle exec rspec`, `bundle exec brakeman`, `bundle exec rubocop`, and a manual pass through the golden path in a browser.

---

*End of CLAUDE.md — aligned to SystemOrEcosystem Rails Rebuild Brief v1.0.*
