namespace :seed do
  desc "Seed ONLY the testimonial letters (the scrolling wall near the bottom of the home page)"
  task letters: :environment do
    letters = [
      { quote: "THANK YOU!!!!!!!!! I just listened, but I would like to re-read on paper. I could not stop listening. I say this with tears, thank you!!!!!!!!!!!!!!!", attribution: "— A woman, New York" },
      { quote: "I have never read anything like this. Its simplicity undid me. The Lord used it to shift something in me that I have been wrestling with for years.", attribution: "— Reader, Accra" },
      { quote: "Finished both volumes in one weekend. Felt like I was being spoken to directly.", attribution: "— Reader, Manila" },
      { quote: "I keep coming back to chapter two. Something about \"algorithm to organism\" — it named a thing I could not name.", attribution: "— Reader, Lagos" },
      { quote: "I read this in the hospital. It was the book I needed that week.", attribution: "— Reader, São Paulo" },
      { quote: "Passing my copy around my small group. Everyone is gonna need their own.", attribution: "— Small group leader, Austin" },
      { quote: "My husband does not read much. He read this. Twice.", attribution: "— Reader, Lisbon" },
      { quote: "I have not heard Jesus explained this way before. Thank you for writing something honest.", attribution: "— Reader, London" },
      { quote: "Raw and gentle at the same time. Hard to pull off. You pulled it off.", attribution: "— Reader, Nairobi" }
    ]

    SiteSetting["testimonial_letters"] = letters.to_json
    puts "✓ Seeded #{letters.size} testimonial letters into SiteSetting['testimonial_letters']"
  end

  desc "Seed ONLY the home page content SiteSettings (hero, manifesto, pillars, CTA, footer, author, shoutout)"
  task home_content: :environment do
    require Rails.root.join("db/seeds_helpers/home_content") if File.exist?(Rails.root.join("db/seeds_helpers/home_content.rb"))
    puts "→ Re-run full db:seed or edit /admin/home directly for now."
  end
end
