FactoryBot.define do
  factory :book_translation do
    book { nil }
    locale { "MyString" }
    title { "MyString" }
    description { "MyText" }
    tagline { "MyString" }
    slug { "MyString" }
  end
end
