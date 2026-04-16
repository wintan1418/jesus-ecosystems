module ApplicationHelper
  # Read editable content from SiteSetting with an i18n fallback.
  #
  # Usage:
  #   <%= cms("hero_headline_1", default: t("home.headline_1")) %>
  #   <%= cms("testimonials", default: "[]") %>  # JSON blobs round-trip as strings
  def cms(key, default: nil)
    value = SiteSetting[key]
    value.present? ? value : default
  end

  # Parse a JSON SiteSetting into a Ruby array, returning [] on parse error.
  def cms_json(key, default: [])
    raw = SiteSetting[key].to_s
    return default if raw.blank?
    JSON.parse(raw)
  rescue JSON::ParserError
    default
  end

  # Read a CMS value and convert raw newlines into <br> tags so editors can
  # control line breaks directly from the admin textarea. Use only when the
  # field is intentionally multi-line (e.g. headlines).
  def cms_lines(key, default: nil)
    raw = cms(key, default: default).to_s
    safe_join(raw.split(/\r?\n/), tag.br)
  end
end
