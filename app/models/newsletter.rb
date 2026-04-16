class Newsletter < ApplicationRecord
  has_rich_text :body

  belongs_to :sent_by, class_name: "Admin", optional: true

  validates :subject, presence: true
  validates :locale,  presence: true, inclusion: { in: %w[en es pt] }

  scope :sent,    -> { where.not(sent_at: nil) }
  scope :draft,   -> { where(sent_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  def sent?
    sent_at.present?
  end

  def status
    return "sent"      if sent?
    return "scheduled" if scheduled_for.present? && scheduled_for > Time.current
    "draft"
  end

  # The subscriber list this broadcast targets.
  def recipients
    EmailSubscriber.subscribed.where(locale: locale)
  end
end
