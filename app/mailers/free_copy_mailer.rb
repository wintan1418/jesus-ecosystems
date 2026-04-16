class FreeCopyMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "hello@systemorecosystem.com")

  # Sent to the requester after they submit the form (only if they gave an email).
  def confirmation(request)
    @request = request
    mail(
      to:      @request.email,
      subject: "We've got your request — books incoming · #{ENV.fetch('SITE_NAME', 'SystemOrEcosystem')}"
    )
  end

  # Sent to the admin every time a new request lands.
  def admin_notification(request)
    @request = request
    mail(
      to:      ENV.fetch("ADMIN_EMAIL", "admin@systemorecosystem.com"),
      subject: "[New request] #{request.full_name} · #{request.country} · #{request.book_summary}"
    )
  end
end
