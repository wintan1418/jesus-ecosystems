SitemapGenerator::Sitemap.default_host = ENV.fetch("SITE_URL", "https://systemorecosystem.com")

SitemapGenerator::Sitemap.create do
  %w[en es pt].each do |loc|
    # Root + static pages
    add "/#{loc}",           changefreq: "weekly",  priority: 1.0,  alternates: alternate_locales_for("/")
    add "/#{loc}/about",     changefreq: "monthly", priority: 0.7,  alternates: alternate_locales_for("/about")
    add "/#{loc}/books",     changefreq: "weekly",  priority: 0.9,  alternates: alternate_locales_for("/books")
    add "/#{loc}/audiobooks", changefreq: "weekly", priority: 0.8,  alternates: alternate_locales_for("/audiobooks")
    add "/#{loc}/request-free-copy", changefreq: "monthly", priority: 0.8

    # Books (slugs are the same across locales, localized content via translations)
    Book.published.each do |book|
      add "/#{loc}/books/#{book.slug}",      changefreq: "monthly", priority: 0.8
      add "/#{loc}/books/#{book.slug}/read", changefreq: "monthly", priority: 0.7

      book.chapters.for_locale(loc).where(is_preview: true).each do |chapter|
        add "/#{loc}/books/#{book.slug}/chapters/#{chapter.slug}",
            changefreq: "monthly", priority: 0.5
      end
    end

    # Audiobooks
    Audiobook.for_locale(loc).find_each do |ab|
      add "/#{loc}/audiobooks/#{ab.id}", changefreq: "monthly", priority: 0.5
    end
  end
end

# Build hreflang alternates for a given path — returns a list of {href, lang}
def alternate_locales_for(path)
  %w[en es pt].map do |loc|
    { href: "https://systemorecosystem.com/#{loc}#{path == '/' ? '' : path}", lang: loc }
  end
end
