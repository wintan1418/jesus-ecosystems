class BookTranslation < ApplicationRecord
  belongs_to :book

  validates :locale, presence: true,
                     inclusion: { in: %w[en es pt] },
                     uniqueness: { scope: :book_id }
  validates :title, :slug, presence: true
  validates :slug,  uniqueness: { scope: :locale }
end
