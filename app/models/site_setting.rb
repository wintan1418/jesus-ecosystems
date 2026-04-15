class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.[](key)
    Rails.cache.fetch("site_setting/#{key}") { find_by(key: key.to_s)&.value }
  end

  def self.[]=(key, value)
    record = find_or_initialize_by(key: key.to_s)
    record.update!(value: value)
    Rails.cache.delete("site_setting/#{key}")
  end

  after_save    { Rails.cache.delete("site_setting/#{key}") }
  after_destroy { Rails.cache.delete("site_setting/#{key}") }
end
