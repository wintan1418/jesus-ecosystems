# We don't attribute visits to users (privacy-friendly page-view tracking),
# so the :user association is intentionally removed — it otherwise crashes
# because we have no User model, only Admin.
class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
end
