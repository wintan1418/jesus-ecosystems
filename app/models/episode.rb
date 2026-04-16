class Episode < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_rich_text    :body
  has_one_attached :audio_file
  has_one_attached :cover_image

  validates :title,  presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }
  validates :season, numericality: { only_integer: true, greater_than: 0 }
  validates :number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :published,  -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :for_locale, ->(loc) { where(locale: loc.to_s) }
  scope :recent,     -> { order(published_at: :desc) }
  scope :ordered,    -> { order(season: :desc, number: :desc, published_at: :desc) }

  def published?
    published_at.present? && published_at <= Time.current
  end

  def duration
    return nil unless duration_seconds
    Time.at(duration_seconds).utc.strftime(duration_seconds >= 3600 ? "%H:%M:%S" : "%M:%S")
  end

  # iTunes <itunes:duration> format — HH:MM:SS or MM:SS
  def itunes_duration
    duration || "00:00"
  end

  def label
    parts = []
    parts << "S#{season}"
    parts << "E#{number}" if number
    parts.join(" · ")
  end
end
