class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      pending:    FreeCopyRequest.where(status: "pending").count,
      fulfilling: FreeCopyRequest.where(status: "fulfilling").count,
      shipped_24: FreeCopyRequest.where(status: "shipped").where(updated_at: 24.hours.ago..).count,
      subscribers: EmailSubscriber.subscribed.count,
      books:      Book.count,
      chapters:   Chapter.count,
      preview:    Chapter.where(is_preview: true).count,
      audiobooks: Audiobook.count
    }
    @recent_requests    = FreeCopyRequest.recent.limit(6)
    @recent_subscribers = EmailSubscriber.order(created_at: :desc).limit(5)
  end
end
