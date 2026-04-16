class FreeCopyRequest < ApplicationRecord
  STATUSES = %w[pending fulfilling shipped cancelled].freeze

  enum :status, STATUSES.index_with(&:itself)

  validates :first_name, :last_name, presence: true
  # Email is optional per the designer's spec — only validate format when present.
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :address_line_1, :city, :state_province, :postal_code, :country, presence: true
  validates :locale, presence: true, inclusion: { in: %w[en es pt] }
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :qty_vol_1,       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :qty_vol_1_combo, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :must_request_at_least_one_book

  before_save :sync_volumes_from_quantities

  scope :recent,     -> { order(created_at: :desc) }
  scope :for_status, ->(s) { where(status: s) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def total_books
    qty_vol_1.to_i + qty_vol_1_combo.to_i
  end

  def book_summary
    parts = []
    parts << "#{qty_vol_1} × Vol. 1 Intro"           if qty_vol_1.to_i.positive?
    parts << "#{qty_vol_1_combo} × Vol. 1 & 2 Combo" if qty_vol_1_combo.to_i.positive?
    parts.join(" · ")
  end

  private

  def must_request_at_least_one_book
    return if qty_vol_1.to_i.positive? || qty_vol_1_combo.to_i.positive?
    errors.add(:base, "Pick at least one book — set a quantity above zero.")
  end

  # Keep volumes_requested in sync with the quantity columns so the array
  # stays useful for filters/exports without callers having to set it.
  def sync_volumes_from_quantities
    vols = []
    vols << "1"     if qty_vol_1.to_i.positive?
    vols << "combo" if qty_vol_1_combo.to_i.positive?
    self.volumes_requested = vols
  end
end
