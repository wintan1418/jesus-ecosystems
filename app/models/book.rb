class Book < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_one_attached :cover_image
  has_many :translations, class_name: "BookTranslation", dependent: :destroy
  has_many :chapters, dependent: :destroy
  has_many :audiobooks, dependent: :destroy

  acts_as_list column: :position

  validates :title,         presence: true
  validates :volume_number, presence: true, uniqueness: true,
                            inclusion: { in: [1, 2] }

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :ordered,   -> { order(:position) }

  def translation_for(locale)
    translations.find_by(locale: locale.to_s) || translations.find_by(locale: I18n.default_locale.to_s)
  end

  def localized_title(locale)       = translation_for(locale)&.title       || title
  def localized_description(locale) = translation_for(locale)&.description || description
  def localized_tagline(locale)     = translation_for(locale)&.tagline     || tagline
end
