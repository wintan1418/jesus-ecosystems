FactoryBot.define do
  factory :book do
    title { "MyString" }
    volume_number { 1 }
    slug { "MyString" }
    description { "MyText" }
    tagline { "MyString" }
    published_at { "2026-04-15 20:09:36" }
    position { 1 }
  end
end
