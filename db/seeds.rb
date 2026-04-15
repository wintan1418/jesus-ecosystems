# Idempotent seeds for the SystemOrEcosystem book platform.
# Run with: bin/rails db:seed

require "open-uri"

puts "→ Seeding books and translations…"

BOOK_DATA = [
  {
    volume_number: 1,
    title:    "The System or The Ecosystem — Volume One",
    tagline:  "From needy to noteworthy.",
    description: "How Jesus refines ordinary people for Jesus-sized outcomes. A raw and honest look at how Jesus turns chaos into His community — without algorithms, club rules, or scaffolding.",
    cover_path: Rails.root.join("public/source-assets/volume-1.jpg"),
    translations: {
      "en" => { title: "The System or The Ecosystem — Volume One",
                tagline: "From needy to noteworthy.",
                description: "How Jesus refines ordinary people for Jesus-sized outcomes." },
      "es" => { title: "El Sistema o El Ecosistema — Volumen Uno",
                tagline: "De necesitados a notables.",
                description: "Cómo Jesús refina a personas comunes para resultados del tamaño de Jesús." },
      "pt" => { title: "O Sistema ou O Ecossistema — Volume Um",
                tagline: "De necessitados a notáveis.",
                description: "Como Jesus refina pessoas comuns para resultados do tamanho de Jesus." }
    },
    chapters: {
      "en" => [
        { title: "The Crew He Picks",       preview: true,
          body: "He didn't pick the credentialed. He picked fishermen, tax collectors, doubters and zealots. The first qualification of an ecosystem is that it accepts what the system rejects." },
        { title: "From Algorithm to Organism", preview: true,
          body: "Algorithms optimize for the average. Organisms grow toward the light. Jesus is in the second business." },
        { title: "When Performance Stops",  preview: false,
          body: "Religion taught us how to perform. Jesus invites us to stop performing and start breathing." },
        { title: "The Work of Belonging",   preview: false,
          body: "Belonging is not earned, but it is built — quietly, daily, in the small acts of mutual air." }
      ],
      "es" => [
        { title: "La Tripulación que Elige", preview: true,
          body: "No eligió a los credenciales. Eligió a pescadores, recaudadores de impuestos, dudosos y zelotes." },
        { title: "Del Algoritmo al Organismo", preview: true,
          body: "Los algoritmos optimizan para el promedio. Los organismos crecen hacia la luz." },
        { title: "Cuando la Actuación Cesa", preview: false,
          body: "La religión nos enseñó a actuar. Jesús nos invita a dejar de actuar y empezar a respirar." }
      ],
      "pt" => [
        { title: "A Tripulação que Ele Escolhe", preview: true,
          body: "Ele não escolheu os credenciados. Escolheu pescadores, coletores de impostos, duvidosos e zelotes." },
        { title: "Do Algoritmo ao Organismo", preview: true,
          body: "Algoritmos otimizam para a média. Organismos crescem em direção à luz." },
        { title: "Quando a Performance Cessa", preview: false,
          body: "A religião nos ensinou a performar. Jesus nos convida a parar de performar e começar a respirar." }
      ]
    }
  },
  {
    volume_number: 2,
    title:    "The System or The Ecosystem — Volume Two",
    tagline:  "From mundane to mountain-movers.",
    description: "Jesus doesn't build systems. He grows stories that move. Volume Two follows the disciples from chaos into community, and from community into world-changing.",
    cover_path: Rails.root.join("public/source-assets/volume-2.jpg"),
    translations: {
      "en" => { title: "The System or The Ecosystem — Volume Two",
                tagline: "From mundane to mountain-movers.",
                description: "Jesus doesn't build systems. He grows stories that move." },
      "es" => { title: "El Sistema o El Ecosistema — Volumen Dos",
                tagline: "De comunes a mueve-montañas.",
                description: "Jesús no construye sistemas. Cultiva historias que se mueven." },
      "pt" => { title: "O Sistema ou O Ecossistema — Volume Dois",
                tagline: "De comuns a movedores de montanhas.",
                description: "Jesus não constrói sistemas. Ele cultiva histórias que se movem." }
    },
    chapters: {
      "en" => [
        { title: "Stories That Move",       preview: true,
          body: "A story does what a system can never do: it moves. It re-arranges the inside of the listener." },
        { title: "The Long Obedience",      preview: false,
          body: "Faith is not a sprint or a stage. It is a long obedience in the same green direction." },
        { title: "Mountains, Mustard Seeds", preview: false,
          body: "The mountain doesn't need to be loud to move. The mustard seed doesn't need to be big to grow." }
      ],
      "es" => [
        { title: "Historias que se Mueven", preview: true,
          body: "Una historia hace lo que un sistema nunca puede: se mueve. Reorganiza el interior del oyente." },
        { title: "La Larga Obediencia",     preview: false,
          body: "La fe no es un sprint ni un escenario. Es una larga obediencia en la misma dirección verde." }
      ],
      "pt" => [
        { title: "Histórias que se Movem",  preview: true,
          body: "Uma história faz o que um sistema nunca pode: ela se move." },
        { title: "A Longa Obediência",      preview: false,
          body: "A fé não é uma corrida nem um palco. É uma longa obediência na mesma direção verde." }
      ]
    },
  }
]

# ── Books ───────────────────────────────────────────────────────────────────
BOOK_DATA.each do |data|
  book = Book.find_or_initialize_by(volume_number: data[:volume_number])
  book.title       = data[:title]
  book.tagline     = data[:tagline]
  book.description = data[:description]
  book.published_at ||= Time.current
  book.position    = data[:volume_number]
  book.save!

  # Cover image — only attach if not already attached
  if data[:cover_path].exist? && !book.cover_image.attached?
    book.cover_image.attach(io: data[:cover_path].open, filename: data[:cover_path].basename.to_s, content_type: "image/jpeg")
  end

  # Translations
  data[:translations].each do |locale, attrs|
    t = book.translations.find_or_initialize_by(locale: locale)
    t.title       = attrs[:title]
    t.tagline     = attrs[:tagline]
    t.description = attrs[:description]
    t.slug        = attrs[:title].parameterize
    t.save!
  end

  # Chapters
  data[:chapters].each do |locale, chapters|
    chapters.each_with_index do |c, i|
      ch = book.chapters.find_or_initialize_by(locale: locale, slug: c[:title].parameterize)
      ch.title       = c[:title]
      ch.is_preview  = c[:preview]
      ch.position    = i + 1
      ch.save!
      ch.body = c[:body] if ch.body.blank?
      ch.save!
    end
  end

  # Audiobooks — one per locale, pointing at the JWPlayer HLS as a placeholder
  %w[en es pt].each do |locale|
    ab = book.audiobooks.find_or_initialize_by(locale: locale)
    ab.title            = "#{book.title} (#{locale.upcase})"
    ab.duration_seconds = 60 * 60 * 6 # 6 hours, placeholder
    ab.position         = book.volume_number
    ab.save!
  end
end

puts "→ Seeding site settings (shoutout + testimonials)…"
{
  "shoutout_video_url" => "", # Paste the real video URL in the admin CMS → SiteSettings
  "shoutout_poster_url" => "https://images.unsplash.com/photo-1507692049790-de58290a4334?w=1400&q=80&auto=format&fit=crop",
  "shoutout_label" => "A word from the author",
  "shoutout_cta" => "Play the message",
  "testimonials" => [
    { quote: "Jesus doesn't build systems. He grows stories that move.", attribution: "— Volume One" },
    { quote: "Where faith stops performing and starts breathing.", attribution: "— Volume Two" },
    { quote: "Religion is a club, a vibe and rules. Jesus came to blow that up.", attribution: "— From the manifesto" },
    { quote: "Jesus redefines growth — from algorithm to organism.", attribution: "— Volume Two" },
    { quote: "He refines ordinary people for Jesus-sized outcomes.", attribution: "— Volume One" }
  ].to_json
}.each do |key, value|
  SiteSetting.find_or_initialize_by(key: key).update!(value: value)
end

puts "→ Seeding admin user…"
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@systemorecosystem.com")
admin = Admin.find_or_initialize_by(email: admin_email)
admin.password = ENV.fetch("ADMIN_PASSWORD", "changeme123")
admin.save!

puts "✓ Done. #{Book.count} books · #{Chapter.count} chapters · #{Audiobook.count} audiobooks · #{Admin.count} admin"
