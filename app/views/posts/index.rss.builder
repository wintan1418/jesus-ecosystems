xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title       "#{t('site.name')} · Journal"
    xml.description "Fragments, discoveries and corrections between volumes."
    xml.link        journal_url(locale: I18n.locale)
    xml.language    I18n.locale.to_s
    xml.tag! "atom:link", href: journal_rss_url(locale: I18n.locale), rel: "self", type: "application/rss+xml"

    @posts.each do |post|
      xml.item do
        xml.title       post.title
        xml.description post.excerpt
        xml.pubDate     post.published_at.rfc2822
        xml.link        post_url(post.slug, locale: I18n.locale)
        xml.guid        post_url(post.slug, locale: I18n.locale), isPermaLink: "true"
        xml.author      post.author_name if post.author_name.present?
      end
    end
  end
end
