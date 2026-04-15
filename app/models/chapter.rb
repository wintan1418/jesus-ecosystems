class Chapter < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: [:book, :locale]

  belongs_to :book
  has_rich_text :body

  acts_as_list column: :position, scope: [:book_id, :locale]

  validates :title,  presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }

  scope :preview,    -> { where(is_preview: true) }
  scope :for_locale, ->(loc) { where(locale: loc.to_s) }
  scope :ordered,    -> { order(:position) }
end
