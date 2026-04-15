FactoryBot.define do
  factory :chapter do
    book { nil }
    title { "MyString" }
    body { "MyText" }
    position { 1 }
    is_preview { false }
    locale { "MyString" }
    slug { "MyString" }
  end
end
