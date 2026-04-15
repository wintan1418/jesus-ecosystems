FactoryBot.define do
  factory :email_subscriber do
    email { "MyString" }
    first_name { "MyString" }
    locale { "MyString" }
    source { "MyString" }
    confirmed_at { "2026-04-15 20:10:00" }
    unsubscribed_at { "2026-04-15 20:10:00" }
  end
end
