require "fileutils"
require "net/http"
require "uri"
require "socket"
require "json"

# Builds a static HTML/CSS/JS handoff package from the running Rails app.
#
# Usage:  bin/rails handoff:export
#
# Boots a temp Rails server on a free port, curls each public page, rewrites
# asset paths so the output is self-contained, copies the compiled Tailwind
# CSS + Stimulus controllers + media assets, writes a README, and zips the
# whole directory into `ecosystem-handoff-YYYY-MM-DD.zip` at the repo root.
class HandoffExporter
  PAGES = [
    ["/en",                    "index.html"],
    ["/en/about",              "about.html"],
    ["/en/books",              "books.html"],
    ["/en/audiobooks",         "audiobooks.html"],
    ["/en/request-free-copy",  "request-free-copy.html"]
  ].freeze

  def call
    prepare_directory
    build_tailwind
    book_pages = collect_book_pages
    start_server do |port|
      render_pages(port, PAGES + book_pages)
    end
    copy_static_assets
    write_application_js
    write_controllers_index
    write_readme
    zip = zip_bundle
    puts "\n✓ Handoff package: #{zip}"
    puts "  Size: #{File.size(zip) / 1024} KB"
  end

  INLINE_IMPORTMAP_BLOCK = <<~HTML.strip
    <script type="importmap">
    {
      "imports": {
        "application": "./js/application.js",
        "controllers": "./js/controllers/index.js",
        "controllers/": "./js/controllers/",
        "@hotwired/turbo-rails": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8/dist/turbo.es2017-esm.js",
        "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3/dist/stimulus.js",
        "hls.js": "https://esm.sh/hls.js@1.5.13"
      }
    }
    </script>
    <script type="module">import "application"</script>
  HTML

  private

  def out_dir    = Rails.root.join("handoff")
  def css_dir    = out_dir.join("css")
  def js_dir     = out_dir.join("js")
  def assets_dir = out_dir.join("assets")

  def prepare_directory
    FileUtils.rm_rf(out_dir)
    FileUtils.mkdir_p([out_dir, css_dir, js_dir, js_dir.join("controllers"), assets_dir])
  end

  def build_tailwind
    puts "→ Building Tailwind CSS…"
    system("bin/rails tailwindcss:build") or raise "Tailwind build failed"
  end

  # Book slugs aren't stable across environments — derive from the current DB.
  def collect_book_pages
    Book.ordered.map do |book|
      ["/en/books/#{book.slug}", "volume-#{book.volume_number}.html"]
    end
  end

  def start_server
    port     = find_free_port
    log      = Rails.root.join("log/handoff.log")
    pid_file = Rails.root.join("tmp/pids/handoff-server.pid")
    File.write(log, "")
    File.delete(pid_file) if pid_file.exist?

    puts "→ Starting temp server on port #{port}…"
    pid = Process.spawn(
      { "RAILS_ENV" => "development" },
      "bin/rails", "server",
      "-p", port.to_s,
      "-b", "127.0.0.1",
      "-P", pid_file.to_s,
      out: log.to_s, err: log.to_s
    )

    # Poll until /up returns 200. Rails + Puma can take 15–30s to boot in dev,
    # so give it a generous 60s ceiling.
    ready = false
    120.times do
      sleep 0.5
      begin
        Net::HTTP.start("127.0.0.1", port, open_timeout: 2, read_timeout: 5) do |http|
          res = http.get("/up")
          if res.code.to_i == 200
            ready = true
            break
          end
        end
      rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout, EOFError
        next
      end
      break if ready
    end

    raise "Temp server never became healthy — see log/handoff.log" unless ready

    puts "→ Server up. Rendering pages…"
    yield port
  ensure
    if defined?(pid) && pid
      Process.kill("TERM", pid) rescue nil
      Process.wait(pid) rescue nil
    end
  end

  def find_free_port
    server = TCPServer.new("127.0.0.1", 0)
    port   = server.addr[1]
    server.close
    port
  end

  def render_pages(port, pages)
    page_map = pages.to_h
    pages.each do |path, filename|
      uri = URI("http://127.0.0.1:#{port}#{path}")
      res = Net::HTTP.get_response(uri)
      unless res.code.to_i == 200
        warn "  ✗ #{path} → #{res.code}"
        next
      end
      html = rewrite_html(res.body, page_map)
      # Rails responses come back as ASCII-8BIT; binwrite avoids encoding
      # conversion errors on UTF-8 content like the em-dash and smart quotes.
      File.binwrite(out_dir.join(filename), html)
      puts "  ✓ #{path} → #{filename}"
    end
  end

  # Rewrites asset paths + internal links so the bundle is self-contained and
  # opens cleanly on any static host without our Rails dev server.
  def rewrite_html(html, page_map)
    # Internal page links → mapped .html files (or # if not exported)
    html = html.gsub(/href="(\/en[^"\s]*)"/) do
      target = ::Regexp.last_match(1).split("?").first
      if page_map[target]
        %(href="#{page_map[target]}")
      elsif target == "/en" || target == "/en/"
        'href="index.html"'
      else
        'href="#"'
      end
    end

    # Logo / homepage anchor sometimes renders as /?locale=en (default-locale shortcut)
    html.gsub!(/href="\/\?locale=en"/, 'href="index.html"')

    # Compiled CSS → css/styles.css
    html.gsub!(/\/assets\/tailwind-[0-9a-f]+\.css/, "css/styles.css")
    # ActionText CSS (unused in public views) — drop the link tag
    html.gsub!(/<link[^>]*href="\/assets\/actiontext[^"]*"[^>]*>/, "")
    # Dedupe identical stylesheet links (Rails layout includes both `tailwind`
    # and `:app` and they collapse to the same compiled file post-rewrite).
    html.gsub!(
      /(<link rel="stylesheet" href="css\/styles\.css"[^>]*>)\s*\n?\s*<link rel="stylesheet" href="css\/styles\.css"[^>]*>/,
      '\1'
    )

    # Media assets → local paths
    html.gsub!(%r{"/source-assets/}, '"assets/')

    # Favicons live at the Rails public root — point at the bundled copies.
    html.gsub!(%r{href="/icon\.png"}, 'href="assets/icon.png"')
    html.gsub!(%r{href="/icon\.svg"}, 'href="assets/icon.svg"')

    # JS: nuke Rails' importmap, modulepreloads, and bootstrap script — the
    # importmap they emit references hashed dev-server paths that don't ship
    # in the bundle, and external `<script type="importmap" src=...>` is not
    # supported by browsers. We splice in a self-contained inline block instead.
    html.gsub!(/^\s*<link rel="modulepreload"[^>]*>\s*\n?/, "")
    html.sub!(/<script type="module">\s*import "application"\s*<\/script>\s*\n?/, "")
    html.sub!(/<script type="importmap"[^>]*>.*?<\/script>/m, INLINE_IMPORTMAP_BLOCK)

    # Strip dev-server URLs that leak into meta tags. Recipient's domain
    # should populate canonical / og:url at deploy time.
    html.gsub!(/\s*<link rel="canonical"[^>]*>\s*\n?/, "")
    html.gsub!(/\s*<meta property="og:url"[^>]*>\s*\n?/, "")
    # og:image rewrite — keep the tag, point at the bundled cover.
    html.gsub!(/<meta property="og:image"[^>]*content="[^"]*"[^>]*>/,
               '<meta property="og:image" content="assets/volume-1.jpg">')
    # hreflang URLs all point at the dev server and only `en` actually ships.
    html.gsub!(/\s*<link rel="alternate" hreflang="[^"]+"[^>]*>\s*\n?/, "")

    # Language switcher + footer locale list: keep all rows so the receiving
    # team sees the full multi-language UX. Non-EN hrefs point at dev-server
    # locales that won't resolve in a static bundle — neutralize every `href`
    # that starts with `/es`, `/pt`, `/fr`, `/de`, or `/it` to `#` so the
    # dropdown/footer demos the list without 404ing on click.
    html.gsub!(
      /href="\/(?:es|pt|fr|de|it)(?:[\/?][^"]*)?"/,
      'href="#"'
    )

    # Strip Rails-specific attributes and meta tags
    html.gsub!(/ data-turbo-track="reload"/, "")
    html.gsub!(/<meta name="csrf[^"]+"[^>]*>/, "")
    html.gsub!(/<meta name="csp-nonce"[^>]*>/, "")

    # Drop the Rails CSRF input in forms (no Rails backend in the static site)
    html.gsub!(/<input type="hidden" name="authenticity_token"[^>]*>/, "")

    html
  end

  def copy_static_assets
    puts "→ Copying assets…"

    # Compiled Tailwind
    tailwind = Rails.root.join("app/assets/builds/tailwind.css")
    FileUtils.cp(tailwind, css_dir.join("styles.css")) if tailwind.exist?

    # Media (logo + covers)
    Dir[Rails.root.join("public/source-assets/*").to_s].each do |f|
      FileUtils.cp(f, assets_dir) unless File.directory?(f)
    end

    # Favicons (Rails serves these from /public root; the layout links to
    # /icon.png + /icon.svg, which we rewrite to assets/ in `rewrite_html`).
    %w[icon.png icon.svg].each do |f|
      src = Rails.root.join("public", f)
      FileUtils.cp(src, assets_dir.join(f)) if src.exist?
    end

    # Stimulus controllers — skip the Rails-specific entry files; we generate
    # clean replacements in `write_application_js` and `write_controllers_index`.
    skip = %w[application.js index.js]
    Dir[Rails.root.join("app/javascript/controllers/*.js").to_s].each do |f|
      next if skip.include?(File.basename(f))
      FileUtils.cp(f, js_dir.join("controllers"))
    end
  end

  # The Rails entry point imports `trix` and `@rails/actiontext`, which only
  # exist in our build. The handoff just needs Turbo + Stimulus controllers.
  def write_application_js
    File.write(js_dir.join("application.js"), <<~JS)
      // Bootstrap: load Turbo for SPA-feel navigation, then register Stimulus controllers.
      import "@hotwired/turbo-rails"
      import "controllers"
    JS
  end

  # Rails' `controllers/index.js` uses stimulus-loading's `eagerLoadControllersFrom`
  # — that helper relies on importmap-rails' build-time enumeration and doesn't
  # work in a plain browser importmap. Generate explicit imports + registers.
  def write_controllers_index
    files = Dir[Rails.root.join("app/javascript/controllers/*_controller.js").to_s].sort

    imports = files.map do |f|
      base = File.basename(f, "_controller.js")
      class_name = base.split("_").map(&:capitalize).join + "Controller"
      "import #{class_name} from \"./#{File.basename(f)}\""
    end

    registers = files.map do |f|
      base = File.basename(f, "_controller.js")
      class_name = base.split("_").map(&:capitalize).join + "Controller"
      identifier = base.tr("_", "-")
      %{application.register("#{identifier}", #{class_name})}
    end

    File.write(js_dir.join("controllers/index.js"), <<~JS)
      import { Application } from "@hotwired/stimulus"

      #{imports.join("\n")}

      const application = Application.start()
      application.debug = false
      window.Stimulus = application

      #{registers.join("\n")}

      export { application }
    JS
  end

  def write_readme
    File.write(out_dir.join("README.md"), <<~MD)
      # SystemOrEcosystem — Static Handoff
      Generated #{Date.current.strftime('%B %-d, %Y')}

      This package is the public-facing site as static HTML / CSS / JS —
      ready to port into **any** CMS or backend. Nothing here is
      Rails-specific. It's plain semantic HTML, compiled CSS, and ES
      modules. Any stack — PHP, Node, Go, Django, WordPress, custom —
      can host it.

      ## What's in the box

      ```
      index.html              Home page
      about.html              /about — author page
      books.html              Books index
      volume-1.html           Book detail — Volume I
      volume-2.html           Book detail — Volume II
      audiobooks.html         Audiobook listening page
      request-free-copy.html  The free-copy request form

      css/styles.css          Compiled Tailwind CSS (all design tokens baked
                              in — no PostCSS build needed)

      js/application.js       JS entry point (Turbo + Stimulus boot)
      js/controllers/         Stimulus controllers (see table below)
                              `index.js` registers them all explicitly.

      assets/                 logo.png, volume-1.jpg, volume-2.jpg, favicons
      ```

      Each HTML file already has an inline `<script type="importmap">` in the
      `<head>` that resolves Turbo, Stimulus, and hls.js from CDN, plus
      `application` and `controllers` from this bundle. No separate file to
      load — open any page on a static host and it boots.

      ## External references inside the HTML

      These stay as CDN URLs in the rendered pages — none of them are
      Rails-specific, just external services the design leans on:

      - **Google Fonts** — Playfair Display + DM Sans + JetBrains Mono
        (`fonts.googleapis.com`)
      - **Cloudinary** — shoutout video + poster
        (`res.cloudinary.com/wintan1418/...`)
      - **Unsplash** — hero slideshow, pillar photos, CTA image
        (`images.unsplash.com/photo-...`)
      - **hls.js via esm.sh** — hero CRT video engine
        (`esm.sh/hls.js@1.5.13`) — only loads when the CRT mounts

      ## JavaScript: Stimulus controllers (framework-agnostic)

      The JS behaviors are written as **Stimulus** controllers. Stimulus is
      a tiny framework (~8KB gzipped) that reads `data-controller="..."`
      attributes from the HTML and wires up behavior. It works with **any**
      backend — Rails, PHP, Django, Node, static sites — as long as the
      markup is in the page.

      ### Option A — Use the inline importmap that ships in every page (simplest)

      Already done. Each HTML file has this in its `<head>`:

      ```html
      <script type="importmap">
      { "imports": {
          "application": "./js/application.js",
          "controllers": "./js/controllers/index.js",
          "controllers/": "./js/controllers/",
          "@hotwired/turbo-rails": "https://cdn.jsdelivr.net/npm/@hotwired/turbo@8/...",
          "@hotwired/stimulus":    "https://cdn.jsdelivr.net/npm/@hotwired/stimulus@3/...",
          "hls.js":                "https://esm.sh/hls.js@1.5.13"
      }}
      </script>
      <script type="module">import "application"</script>
      ```

      Modern browsers (Chrome 89+, Safari 16.4+, Firefox 108+) support
      importmaps natively. For older browsers, add
      [es-module-shims](https://github.com/guybedford/es-module-shims) before
      the importmap.

      ### Option B — Bundle everything into one file

      Run `npx esbuild js/application.js --bundle --format=esm --outfile=app.bundle.js`
      once. Include `<script type="module" src="app.bundle.js" defer>`.
      Single file, works on any browser, no importmap.

      ### Option C — Port to your framework

      Each controller is a small class reading a handful of `data-*`
      attributes. Reimplementing in React/Vue/Svelte/vanilla JS is
      straightforward — the behaviors are listed below with what they do.

      Each controller wires to HTML via `data-controller="..."` attributes
      already in the markup. They're standalone ES modules and don't depend
      on each other.

      | Controller        | Purpose |
      |-------------------|---------|
      | `hls-video`       | Plays the HLS stream inside the hero CRT |
      | `char-reveal`     | Per-character reveal on the main headline |
      | `tagline-rotator` | Crossfades through rotating taglines |
      | `ken-burns`       | Slideshow transitions on hero background |
      | `parallax`        | Mouse-parallax layer system |
      | `reveal`          | Scroll-triggered fade-in on elements |
      | `counter`         | Stats countdown animation |
      | `scroll-progress` | Top progress bar tied to scroll position |
      | `cursor-spotlight`| Mouse-follow radial gradient |
      | `section-rail`    | Right-side dot nav tracking visible section |
      | `plant-grow`      | SVG plant sprout animation in the footer |
      | `subscribe-form`  | Newsletter form disable/submitted state |
      | `audio-player`    | Custom audio player on the audiobooks page |

      ## Localization

      No language YAML files included. Your CMS handles localization.
      English is the reference source. The language switcher markup is a
      `<details>` dropdown (see `.lang-dropdown` in the CSS) — swap the
      three `<li>` entries for your full language list.

      ## Design tokens

      All eco-* CSS custom properties live in `:root` at the top of
      `styles.css`:

      ```css
      --color-eco-bg: #262b1c;          warm olive-dark
      --color-eco-surface: #313625;     olive-leaf surface
      --color-eco-green: #a3bf64;       warm sage accent
      --color-eco-green-light: #d1dba0; pale olive
      --color-eco-text: #ece6d3;        parchment cream
      --color-eco-white: #f5f0dc;       warm bone white
      --font-display: "Playfair Display", ui-serif, ...
      --font-sans:    "DM Sans", ui-sans-serif, ...
      --font-mono:    "JetBrains Mono", ui-monospace, ...
      ```

      ## Dependencies summary

      **CSS:** nothing. `css/styles.css` is a standalone compiled file.

      **JS (only if you want the interactions):**
      - `@hotwired/stimulus` ~8KB gzipped — powers all the `data-controller`
        behaviors. Load from CDN or npm install.
      - `@hotwired/turbo` ~30KB gzipped — smooth page transitions and form
        submissions. **Optional**. If you skip Turbo, forms still work;
        you just lose the SPA-feel navigation. Safe to drop.
      - `hls.js` ~100KB gzipped — only loaded by the hero CRT video player
        when it mounts. **Optional**. If you skip, replace the `<video>` in
        the CRT with a regular MP4 or remove the hero CRT entirely.

      **Fonts:** Google Fonts (Playfair Display, DM Sans, JetBrains Mono).
      Self-host if you prefer by downloading from Google Fonts and updating
      the `<link>` at the top of each HTML file.

      **Images:** Cloudinary + Unsplash hotlinks. All replaceable — point at
      your own CDN/storage by search-and-replacing the URL prefixes.

      ## Porting checklist

      1. Drop the rendered HTML into your CMS's template slots — the
         markup is semantic and language-agnostic.
      2. Include `css/styles.css` in your site's stylesheet bundle.
      3. Decide on JS integration (Option A/B/C above).
      4. Point the Cloudinary + Unsplash + Google Fonts URLs at your own
         CDN if you want to self-host.
      5. Swap the language dropdown's hardcoded `EN / ES / PT` for your
         full list from the DB.
      6. Wire up the form submits (`<form action="...">`) to your own
         backend endpoints. The form markup is standard — first_name,
         last_name, email, address_line_1, etc. No CSRF token needed
         unless your framework requires one.
    MD
  end

  def zip_bundle
    zip_path = Rails.root.join("ecosystem-handoff-#{Date.current}.zip")
    FileUtils.rm_f(zip_path)

    # Prefer the `zip` CLI if available, otherwise fall back to Python's
    # zipfile (always installed on a standard Ubuntu + WSL host). Both
    # produce a standard .zip the designer can unpack anywhere.
    if system("which zip > /dev/null 2>&1")
      Dir.chdir(out_dir) { system("zip", "-rq", zip_path.to_s, ".") or raise "zip failed" }
    elsif system("which python3 > /dev/null 2>&1")
      system("python3", "-c",
             "import shutil; shutil.make_archive(#{%Q["#{zip_path.sub(/\.zip$/, '')}"]}, 'zip', #{%Q["#{out_dir}"]})") or
        raise "python3 zip fallback failed"
    else
      raise "Neither zip(1) nor python3 is available — can't build the archive"
    end

    zip_path.to_s
  end
end
