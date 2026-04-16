require "ostruct"

class NewsletterMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "hello@systemorecosystem.com")

  # Sent to one subscriber as part of a broadcast.
  def weekly(newsletter, subscriber)
    @newsletter = newsletter
    @subscriber = subscriber
    @site_name  = ENV.fetch("SITE_NAME", "SystemOrEcosystem")
    @site_url   = ENV.fetch("SITE_URL",  "https://systemorecosystem.com")

    mail(
      to:      subscriber.email,
      subject: newsletter.subject,
      reply_to: ENV["MAIL_FROM"]
    )
  end

  # Sent to the admin's own email for preview/testing before broadcast.
  def test(newsletter, recipient_email)
    @newsletter = newsletter
    @subscriber = OpenStruct.new(email: recipient_email, first_name: "(test)")
    @site_name  = ENV.fetch("SITE_NAME", "SystemOrEcosystem")
    @site_url   = ENV.fetch("SITE_URL",  "https://systemorecosystem.com")

    mail(
      to:      recipient_email,
      subject: "[TEST] #{newsletter.subject}"
    )
  end
end
