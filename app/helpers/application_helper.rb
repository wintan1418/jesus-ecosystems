module ApplicationHelper
  # Read editable content from SiteSetting with an i18n fallback.
  #
  # Locale resolution:
  #   1. For non-default locales, check `"#{key}_#{locale}"` first (e.g.
  #      `hero_eyebrow_fr`). Admins can populate these per-locale overrides
  #      from the admin panel without touching code.
  #   2. If no locale-specific override exists in a non-default locale,
  #      return the `default:` arg directly (typically a `t(...)` lookup
  #      that resolves via the locale's YAML). This stops the English CMS
  #      copy from leaking into translated pages.
  #   3. For the default locale (en), keep the original behavior: the
  #      CMS value wins, falling back to the `default:`.
  #
  # Usage:
  #   <%= cms("hero_headline_1", default: t("home.headline_1")) %>
  #   <%= cms("testimonials", default: "[]") %>  # JSON blobs round-trip as strings
  def cms(key, default: nil)
    if I18n.locale != I18n.default_locale
      locale_value = SiteSetting["#{key}_#{I18n.locale}"]
      return locale_value if locale_value.present?
      return default
    end

    value = SiteSetting[key]
    value.present? ? value : default
  end

  # Parse a JSON SiteSetting into a Ruby array, returning [] on parse error.
  # Locale-aware in the same way as `cms` — non-default locales check
  # `"#{key}_#{locale}"` first, then fall back to the supplied default.
  def cms_json(key, default: [])
    raw = if I18n.locale != I18n.default_locale
            (SiteSetting["#{key}_#{I18n.locale}"].presence || "").to_s
          else
            SiteSetting[key].to_s
          end

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
