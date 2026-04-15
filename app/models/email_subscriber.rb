class EmailSubscriber < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }

  before_save { self.email = email.downcase.strip }

  scope :confirmed,  -> { where.not(confirmed_at: nil) }
  scope :subscribed, -> { confirmed.where(unsubscribed_at: nil) }

  def confirmed?    = confirmed_at.present?
  def unsubscribed? = unsubscribed_at.present?
end
