module SeoHelper
  # Per-page Organization schema — emitted on home.
  def organization_jsonld
    {
      "@context" => "https://schema.org",
      "@type"    => "Organization",
      "name"     => t("site.name"),
      "url"      => root_url(locale: I18n.locale),
      "logo"     => SiteSetting["og_image_url"].presence || asset_url_or_nil("icon.png"),
      "sameAs"   => [SiteSetting["twitter_url"], SiteSetting["instagram_url"]].compact
    }.to_json.html_safe
  end

  # Schema.org Book for a Book record.
  def book_jsonld(book)
    {
      "@context"     => "https://schema.org",
      "@type"        => "Book",
      "name"         => book.localized_title(I18n.locale),
      "description"  => book.localized_description(I18n.locale),
      "author"       => { "@type" => "Person", "name" => SiteSetting["author_name"] || t("site.name") },
      "inLanguage"   => I18n.locale.to_s,
      "url"          => book_url(book.slug, locale: I18n.locale),
      "image"        => (book.cover_image.attached? ? url_for(book.cover_image) : nil),
      "bookFormat"   => "https://schema.org/Hardcover",
      "isbn"         => nil
    }.compact.to_json.html_safe
  end

  # Schema.org Article for a Post.
  def post_jsonld(post)
    {
      "@context"        => "https://schema.org",
      "@type"           => "Article",
      "headline"        => post.title,
      "description"     => post.excerpt,
      "datePublished"   => post.published_at&.iso8601,
      "dateModified"    => post.updated_at.iso8601,
      "author"          => { "@type" => "Person", "name" => post.author_name.presence || SiteSetting["author_name"] || t("site.name") },
      "publisher"       => { "@type" => "Organization", "name" => t("site.name") },
      "inLanguage"      => post.locale,
      "url"             => post_url(post.slug, locale: post.locale),
      "image"           => (post.featured_image.attached? ? url_for(post.featured_image) : nil),
      "articleSection"  => "Journal"
    }.compact.to_json.html_safe
  end

  # Render hreflang link tags for the current path across all available locales.
  def hreflang_tags
    return "" unless defined?(request) && request
    current_path = request.path.sub(%r{\A/#{I18n.locale}(?=/|$)}, "")
    I18n.available_locales.map do |loc|
      href = "#{request.protocol}#{request.host_with_port}/#{loc}#{current_path}"
      tag.link(rel: "alternate", hreflang: loc.to_s, href: href)
    end.join("\n").html_safe
  end

  private

  def asset_url_or_nil(name)
    asset_path(name)
  rescue
    nil
  end
end
