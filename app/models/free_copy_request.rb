class FreeCopyRequest < ApplicationRecord
  STATUSES        = %w[pending fulfilling shipped cancelled].freeze
  ALLOWED_VOLUMES = %w[1 2].freeze

  enum :status, STATUSES.index_with(&:itself)

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address_line_1, :city, :state_province, :postal_code, :country, presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }
  validates :status, presence: true, inclusion: { in: STATUSES }

  validate  :volumes_must_be_present_and_valid

  scope :recent,     -> { order(created_at: :desc) }
  scope :for_status, ->(s) { where(status: s) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def volumes_must_be_present_and_valid
    if volumes_requested.blank?
      errors.add(:volumes_requested, :blank)
    elsif (volumes_requested - ALLOWED_VOLUMES).any?
      errors.add(:volumes_requested, :invalid)
    end
  end
end
