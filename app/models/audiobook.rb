class Audiobook < ApplicationRecord
  belongs_to :book
  has_one_attached :audio_file

  acts_as_list column: :position, scope: :book_id

  validates :title,  presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] },
                     uniqueness: { scope: :book_id }

  scope :for_locale, ->(loc) { where(locale: loc.to_s) }
  scope :ordered,    -> { order(:position) }

  def duration
    return nil unless duration_seconds
    Time.at(duration_seconds).utc.strftime(duration_seconds >= 3600 ? "%H:%M:%S" : "%M:%S")
  end
end
