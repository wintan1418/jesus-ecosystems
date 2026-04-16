<%# iTunes-compatible podcast RSS feed.
    Validates against https://podba.se/validate/ and lists in Apple Podcasts. %>
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0",
        "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "xmlns:atom"   => "http://www.w3.org/2005/Atom",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do

  podcast_title    = SiteSetting["podcast_title"].presence    || "The Ecosystem Podcast"
  podcast_subtitle = SiteSetting["podcast_subtitle"].presence || "Field notes from the movement."
  podcast_author   = SiteSetting["podcast_author"].presence   || t("site.name")
  podcast_email    = SiteSetting["podcast_owner_email"].presence || "hello@systemorecosystem.com"
  podcast_category = SiteSetting["podcast_category"].presence || "Religion & Spirituality"
  podcast_cover    = SiteSetting["podcast_cover_url"].presence ||
                     "https://images.unsplash.com/photo-1490127252417-7c393f993ee4?w=1400&q=80"

  xml.channel do
    xml.title       podcast_title
    xml.description podcast_subtitle
    xml.link        podcast_url(locale: I18n.locale)
    xml.language    I18n.locale.to_s
    xml.copyright   "© #{Date.current.year} #{podcast_author}"
    xml.tag! "atom:link", href: podcast_rss_url(locale: I18n.locale), rel: "self", type: "application/rss+xml"

    # iTunes channel-level metadata
    xml.tag! "itunes:author",   podcast_author
    xml.tag! "itunes:summary",  podcast_subtitle
    xml.tag! "itunes:type",     "episodic"
    xml.tag! "itunes:explicit", "false"
    xml.tag! "itunes:image",    href: podcast_cover
    xml.tag! "itunes:owner" do
      xml.tag! "itunes:name",  podcast_author
      xml.tag! "itunes:email", podcast_email
    end
    xml.tag! "itunes:category", text: podcast_category

    @episodes.each do |ep|
      xml.item do
        xml.title       ep.title
        xml.description ep.description.to_s
        xml.pubDate     ep.published_at.rfc2822
        xml.link        episode_url(ep.slug, locale: I18n.locale)
        xml.guid        episode_url(ep.slug, locale: I18n.locale), isPermaLink: "true"

        if ep.audio_file.attached?
          xml.enclosure url:  url_for(ep.audio_file),
                        type: ep.audio_file.content_type,
                        length: ep.audio_file.byte_size
        end

        xml.tag! "itunes:title",      ep.title
        xml.tag! "itunes:author",     podcast_author
        xml.tag! "itunes:summary",    ep.description.to_s
        xml.tag! "itunes:duration",   ep.itunes_duration
        xml.tag! "itunes:explicit",   ep.explicit ? "true" : "false"
        xml.tag! "itunes:season",     ep.season  if ep.season
        xml.tag! "itunes:episode",    ep.number  if ep.number
        xml.tag! "itunes:episodeType", "full"

        if ep.body.body.present?
          xml.tag!("content:encoded") { |c| c.cdata!(ep.body.to_s) }
        end
      end
    end
  end
end
