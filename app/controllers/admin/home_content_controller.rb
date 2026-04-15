class Admin::HomeContentController < Admin::BaseController
  # Sections defined in one place — the view renders them as grouped cards,
  # the controller stores whatever keys are present via SiteSetting[]=.
  SECTIONS = [
    {
      id: "hero",
      title: "Hero",
      subtitle: "Headline, subhead, taglines, and the lead CTAs.",
      fields: [
        { key: "hero_eyebrow",      label: "Eyebrow",          kind: :text },
        { key: "hero_headline_1",   label: "Headline (line 1)", kind: :text },
        { key: "hero_headline_2",   label: "Headline (line 2 — italic)", kind: :text },
        { key: "hero_subhead",      label: "Subhead",           kind: :textarea, rows: 3 },
        { key: "hero_rotators",     label: "Rotating taglines (JSON array of strings)", kind: :textarea, rows: 4, help: %(Example: ["from needy to noteworthy","from mundane to mountain-movers"]) },
        { key: "hero_cta_primary",  label: "Primary CTA label", kind: :text },
        { key: "hero_cta_ghost",    label: "Secondary CTA label", kind: :text },
        { key: "hero_video_url",    label: "Hero video URL (HLS .m3u8)", kind: :text }
      ]
    },
    {
      id: "manifesto",
      title: "Manifesto",
      subtitle: "The five lines of the Faith Rewilded band.",
      fields: [
        { key: "manifesto_headline", label: "Headline label", kind: :text },
        { key: "manifesto_one",   label: "Paragraph 1 (large)", kind: :textarea, rows: 4 },
        { key: "manifesto_two",   label: "Paragraph 2", kind: :textarea, rows: 3 },
        { key: "manifesto_three", label: "Paragraph 3", kind: :textarea, rows: 3 },
        { key: "manifesto_four",  label: "Paragraph 4", kind: :textarea, rows: 3 },
        { key: "manifesto_five",  label: "Paragraph 5", kind: :textarea, rows: 3 }
      ]
    },
    {
      id: "pillars",
      title: "Faith Rewilded pillars",
      subtitle: "Four cards under Faith Rewilded.",
      fields: [
        { key: "pillar_one_title",   label: "Pillar 1 · title", kind: :text },
        { key: "pillar_one_body",    label: "Pillar 1 · body",  kind: :textarea, rows: 2 },
        { key: "pillar_two_title",   label: "Pillar 2 · title", kind: :text },
        { key: "pillar_two_body",    label: "Pillar 2 · body",  kind: :textarea, rows: 2 },
        { key: "pillar_three_title", label: "Pillar 3 · title", kind: :text },
        { key: "pillar_three_body",  label: "Pillar 3 · body",  kind: :textarea, rows: 2 },
        { key: "pillar_four_title",  label: "Pillar 4 · title", kind: :text },
        { key: "pillar_four_body",   label: "Pillar 4 · body",  kind: :textarea, rows: 2 }
      ]
    },
    {
      id: "shoutout",
      title: "Shoutout video",
      subtitle: "The card on the home page that opens the author's message.",
      fields: [
        { key: "shoutout_video_url",  label: "Video URL (mp4 / HLS)", kind: :text },
        { key: "shoutout_poster_url", label: "Poster image URL",       kind: :text },
        { key: "shoutout_label",      label: "Label (top-left badge)", kind: :text },
        { key: "shoutout_cta",        label: "CTA title",              kind: :text }
      ]
    },
    {
      id: "testimonials",
      title: "Testimonial quotes",
      subtitle: "Auto-rotating quotes on the Voices band. Paste a JSON array.",
      fields: [
        { key: "testimonials",
          label: "Quotes (JSON array)",
          kind: :textarea, rows: 10,
          help: %([{"quote":"Jesus doesn't build systems...","attribution":"— Volume One"}, ...]) }
      ]
    },
    {
      id: "quote",
      title: "Pull quote band",
      subtitle: "The giant italic quote between sections.",
      fields: [
        { key: "quote",             label: "Quote body",   kind: :textarea, rows: 3 },
        { key: "quote_attribution", label: "Attribution",  kind: :text }
      ]
    },
    {
      id: "cta",
      title: "CTA band",
      subtitle: "The dark band before the footer.",
      fields: [
        { key: "cta_headline", label: "Headline", kind: :textarea, rows: 2 },
        { key: "cta_body",     label: "Body",     kind: :textarea, rows: 3 },
        { key: "cta_button",   label: "Button label", kind: :text }
      ]
    },
    {
      id: "footer",
      title: "Footer",
      subtitle: "Footer tagline + newsletter copy.",
      fields: [
        { key: "footer_tagline",    label: "Tagline",          kind: :text },
        { key: "footer_manifesto",  label: "Short manifesto",  kind: :textarea, rows: 3 },
        { key: "subscribe_heading", label: "Subscribe heading", kind: :text },
        { key: "subscribe_body",    label: "Subscribe body",    kind: :textarea, rows: 2 }
      ]
    },
    {
      id: "author",
      title: "About / Author page",
      subtitle: "The /about page — the face of the movement.",
      fields: [
        { key: "author_name",      label: "Author name",           kind: :text },
        { key: "author_title",     label: "Title / role line",     kind: :text },
        { key: "author_photo_url", label: "Photo URL",             kind: :text, help: "Direct URL to a portrait image." },
        { key: "author_bio",       label: "Short bio",             kind: :textarea, rows: 4 },
        { key: "author_quote",     label: "Signature quote",       kind: :textarea, rows: 3 },
        { key: "author_journey",   label: "The journey narrative", kind: :textarea, rows: 4 }
      ]
    }
  ].freeze

  def edit
    @sections = SECTIONS
    @values   = load_values
  end

  def update
    (params[:site_setting] || {}).each do |key, value|
      next unless known_key?(key)
      SiteSetting[key] = value.to_s
    end
    redirect_to admin_home_content_path, notice: "Home content updated."
  end

  private

  def load_values
    keys = SECTIONS.flat_map { |s| s[:fields].map { |f| f[:key] } }
    SiteSetting.where(key: keys).pluck(:key, :value).to_h
  end

  def known_key?(key)
    @known_keys ||= SECTIONS.flat_map { |s| s[:fields].map { |f| f[:key] } }.to_set
    @known_keys.include?(key.to_s)
  end
end
