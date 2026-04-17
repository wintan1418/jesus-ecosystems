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

  desc "Re-attach book cover images from the latest public/source-assets files"
  task covers: :environment do
    covers = {
      1 => Rails.root.join("public/source-assets/volume-1.jpg"),
      2 => Rails.root.join("public/source-assets/volume-2.jpg")
    }

    covers.each do |vol, path|
      book = Book.find_by(volume_number: vol)
      unless book
        puts "  ✗ Volume #{vol} not found in DB"
        next
      end
      unless path.exist?
        puts "  ✗ #{path} missing on disk"
        next
      end
      book.cover_image.purge if book.cover_image.attached?
      book.cover_image.attach(
        io: path.open,
        filename: path.basename.to_s,
        content_type: "image/jpeg"
      )
      puts "  ✓ Volume #{vol} cover re-attached from #{path.basename}"
    end
    puts "✓ Done."
  end
end
