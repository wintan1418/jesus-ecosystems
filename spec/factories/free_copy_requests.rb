FactoryBot.define do
  factory :free_copy_request do
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address_line_1 { "MyString" }
    address_line_2 { "MyString" }
    city { "MyString" }
    state_province { "MyString" }
    postal_code { "MyString" }
    country { "MyString" }
    locale { "MyString" }
    status { "MyString" }
    notes { "MyText" }
    ip_address { "MyString" }
  end
end
