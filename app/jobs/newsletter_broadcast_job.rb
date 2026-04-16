class NewsletterBroadcastJob < ApplicationJob
  queue_as :default

  # Iterates the broadcast's recipients and enqueues an individual delivery
  # job per subscriber so a flaky inbox doesn't fail the whole batch.
  def perform(newsletter_id)
    newsletter = Newsletter.find(newsletter_id)
    return if newsletter.sent?

    count = 0
    newsletter.recipients.find_each(batch_size: 100) do |subscriber|
      NewsletterMailer.weekly(newsletter, subscriber).deliver_later
      count += 1
    end

    newsletter.update!(sent_at: Time.current, recipients_count: count)
  end
end
