FactoryBot.define do
  factory :audiobook do
    book { nil }
    locale { "MyString" }
    title { "MyString" }
    duration_seconds { 1 }
    position { 1 }
  end
end
