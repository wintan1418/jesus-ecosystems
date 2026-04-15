class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_rich_text    :body
  has_one_attached :featured_image

  validates :title, presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }

  scope :published,  -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :for_locale, ->(loc) { where(locale: loc.to_s) }
  scope :recent,     -> { order(published_at: :desc) }

  # Comma-separated tags round-tripped as an array.
  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def tag_list=(value)
    self.tags = Array(value.is_a?(String) ? value.split(",") : value)
                 .map(&:to_s).map(&:strip).reject(&:blank?).join(", ")
  end

  def reading_time
    mins = reading_minutes.to_i
    mins.positive? ? "#{mins} min read" : "short read"
  end

  def published?
    published_at.present? && published_at <= Time.current
  end
end
