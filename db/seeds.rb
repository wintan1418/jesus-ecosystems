# Idempotent seeds for the SystemOrEcosystem book platform.
# Run with: bin/rails db:seed

require "open-uri"

puts "→ Seeding books and translations…"

BOOK_DATA = [
  {
    volume_number: 1,
    title:    "The System or The Ecosystem — Volume One",
    tagline:  "From needy to noteworthy.",
    description: "An action toolkit for how Jesus refines ordinary people for Jesus-sized outcomes. A raw and honest look at how Jesus turns chaos into His community — without algorithms, club rules, or scaffolding.",
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

puts "→ Seeding site settings (hero, manifesto, shoutout, testimonials, CTA, footer)…"
home_content = {
  # Hero
  "hero_eyebrow"     => "A Two-Volume Christian Action Toolkit",
  # Newlines become <br> via cms_lines() so the editor controls breaks.
  "hero_headline_1"  => "Jesus the\nDesigner's Plan",
  "hero_headline_2"  => "to Change\nthe World.",
  "hero_subhead"     => "A fresh look at how Jesus takes His crew — from chaos into community, from community into world-changing.",
  "hero_rotators"    => [
    "from needy to noteworthy",
    "from mundane to mountain-movers",
    "from struggling to legendary"
  ].to_json,
  "hero_cta_primary" => "Request FREE Hardcopies",
  "hero_cta_ghost"   => "Listen Free",

  # Manifesto
  "manifesto_headline" => "Faith, Rewilded.",
  "manifesto_one"   => "The way Jesus builds world-changers hasn't aged a day. He refines ordinary people for Jesus-sized outcomes. This is a raw and honest look at how Jesus turns chaos into His community.",
  "manifesto_two"   => "Jesus doesn't build systems. He grows stories that move.",
  "manifesto_three" => "Jesus restores what structure forgot. Faith rewilded.",
  "manifesto_four"  => "Where faith stops performing and starts breathing.",
  "manifesto_five"  => "Jesus redefines growth — from algorithm to organism.",

  # Pillars
  "pillar_one_title"   => "Living Roots",
  "pillar_one_body"    => "Communities grow from soil, not from scaffolding.",
  "pillar_two_title"   => "Open Canopy",
  "pillar_two_body"    => "Light enters where the structure is held lightly.",
  "pillar_three_title" => "Wild Order",
  "pillar_three_body"  => "There is design without control.",
  "pillar_four_title"  => "Mutual Air",
  "pillar_four_body"   => "What we breathe out, another breathes in.",

  # Shoutout video
  "shoutout_video_url"  => "",
  "shoutout_poster_url" => "https://images.unsplash.com/photo-1507692049790-de58290a4334?w=1400&q=80&auto=format&fit=crop",
  "shoutout_label"      => "A word from the author",
  "shoutout_cta"        => "Play the message",

  # Testimonials
  "testimonials" => [
    { quote: "Jesus doesn't build systems. He grows stories that move.", attribution: "— Volume One" },
    { quote: "Where faith stops performing and starts breathing.", attribution: "— Volume Two" },
    { quote: "Religion is a club, a vibe and rules. Jesus came to blow that up.", attribution: "— From the manifesto" },
    { quote: "Jesus redefines growth — from algorithm to organism.", attribution: "— Volume Two" },
    { quote: "He refines ordinary people for Jesus-sized outcomes.", attribution: "— Volume One" }
  ].to_json,

  # Pull quote
  "quote"             => "Religion is typically about a club, a vibe, and rules — Jesus came to blow that up.",
  "quote_attribution" => "From Volume One",

  # CTA band
  "cta_headline" => "Get the books, free, in your hands",
  "cta_body"     => "100% free hardcopies. Worldwide shipping. No strings.",
  "cta_button"   => "Request FREE Hardcopies",

  # Footer
  "footer_tagline"    => "Faith, rewilded.",
  "footer_manifesto"  => "Jesus restores what structure forgot. Faith rewilded.",
  "subscribe_heading" => "Get the next volume in your inbox",
  "subscribe_body"    => "Quarterly dispatches. No spam, ever. Unsubscribe in one click.",

  # Author / About page
  "author_name"      => "SystemOrEcosystem",
  "author_title"     => "Author · Builder · Witness",
  "author_photo_url" => "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80&auto=format&fit=crop",
  "author_bio"       => "I write about Jesus the way a gardener talks about soil — more about what keeps things alive than what makes them measurable. These volumes are field notes from a movement that refuses to be a system.",
  "author_quote"     => "I'd rather plant one thing that grows wild than scaffold a hundred things that never breathe.",
  "author_journey"   => "Started writing Volume One in 2023 between two lives — a quiet one and a loud one — and finished Volume Two in the margins of both. Neither feels finished. That might be the point."
}

home_content.each do |key, value|
  SiteSetting.find_or_initialize_by(key: key).update!(value: value)
end

puts "→ Seeding journal posts…"
[
  {
    title: "Why an ecosystem, not a system",
    excerpt: "Systems measure. Ecosystems belong. Here's why the distinction is the whole book.",
    body: "<p>Systems measure. Ecosystems belong. When Jesus picks His crew, He isn't building a pipeline — He's planting a grove.</p><p>The grove grows slower than the pipeline. But it grows <em>from the inside out</em>, and nothing the pipeline produces can survive a drought. We're learning this again the hard way.</p><p>This journal is where I'll think out loud between volumes — fragments, discoveries, corrections. You're welcome here.</p>",
    reading_minutes: 4,
    tags: "manifesto, ecosystem, preface"
  },
  {
    title: "On writing in the wild",
    excerpt: "Notes on a process that refuses to be a product.",
    body: "<p>I wrote the first volume in coffee shops and living rooms. I'm writing the second one in the margins of a life that is louder than it was.</p><p>Both feel true. Neither feels finished. That might be the point.</p>",
    reading_minutes: 3,
    tags: "process, writing"
  },
  {
    title: "The disciples were not employees",
    excerpt: "A short meditation on the crew Jesus actually picked.",
    body: "<p>He didn't interview them. He didn't check credentials. He walked past boats and tax booths and said <em>follow</em>, and they did.</p><p>Imagine building your company like that. Imagine being so sure of the soil that the seeds almost picked themselves.</p>",
    reading_minutes: 2,
    tags: "volume-one, community"
  }
].each_with_index do |data, i|
  post = Post.find_or_initialize_by(slug: data[:title].parameterize)
  post.title           = data[:title]
  post.locale          = "en"
  post.excerpt         = data[:excerpt]
  post.reading_minutes = data[:reading_minutes]
  post.author_name     = "SystemOrEcosystem"
  post.tags            = data[:tags]
  post.published_at    ||= (i + 1).days.ago
  post.position        = i
  post.save!
  post.body = data[:body] if post.body.body.blank?
  post.save!
end

puts "→ Seeding admin user…"
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@systemorecosystem.com")
admin = Admin.find_or_initialize_by(email: admin_email)
admin.password = ENV.fetch("ADMIN_PASSWORD", "changeme123")
admin.save!

puts "✓ Done. #{Book.count} books · #{Chapter.count} chapters · #{Audiobook.count} audiobooks · #{Post.count} posts · #{Admin.count} admin"
