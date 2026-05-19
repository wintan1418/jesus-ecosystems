class Admin::LanguagesController < Admin::BaseController
  # Friendly editor for the `languages` JSON SiteSetting. Backs the language
  # dropdown in the header + the locale list in the footer.
  #
  # The shape stored in SiteSetting is:
  #   [{ "code" => "en", "name" => "English" }, ...]
  # Codes matching an available_locale route live; codes that don't yet have a
  # YAML translation still appear in the dropdown but fall back to default.
  def edit
    @languages = current_languages
    @available_locales = I18n.available_locales.map(&:to_s)
  end

  def update
    entries = Array(params[:languages]).map do |row|
      code = row[:code].to_s.strip.downcase
      name = row[:name].to_s.strip
      next nil if code.blank? || name.blank?
      { "code" => code, "name" => name }
    end.compact

    # Dedupe by code (last wins) while preserving order
    seen = {}
    entries.each { |e| seen[e["code"]] = e }
    final = seen.values

    SiteSetting.find_or_initialize_by(key: "languages").update!(value: final.to_json)
    redirect_to edit_admin_languages_path, notice: "Languages saved (#{final.size} entries)."
  end

  private

  def current_languages
    raw = SiteSetting["languages"].to_s
    parsed = JSON.parse(raw) rescue []
    return parsed if parsed.is_a?(Array) && parsed.any?

    [
      { "code" => "en", "name" => "English" },
      { "code" => "es", "name" => "Español" },
      { "code" => "pt", "name" => "Português" },
      { "code" => "fr", "name" => "Français" },
      { "code" => "de", "name" => "Deutsch" },
      { "code" => "it", "name" => "Italiano" }
    ]
  end
end
