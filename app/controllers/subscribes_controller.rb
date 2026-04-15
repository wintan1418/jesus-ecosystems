class SubscribesController < ApplicationController
  # Creates an EmailSubscriber via the public footer form. Response renders the
  # subscribe_form Turbo Frame with a success flash so the form swaps in place
  # without a full page reload.
  def create
    email  = params[:email].to_s.strip
    locale = params[:locale].presence_in(%w[en es pt]) || I18n.locale.to_s
    source = params[:source].to_s.presence || "footer"

    subscriber = EmailSubscriber.find_or_initialize_by(email: email.downcase)
    subscriber.locale = locale
    subscriber.source ||= source

    if subscriber.save
      flash.now[:subscribed] = "You're in. Look for us in your inbox."
    else
      flash.now[:subscribe_error] = subscriber.errors.full_messages.first || "Something went wrong."
    end

    respond_to do |format|
      format.html { redirect_to request.referer || root_path }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("subscribe_form", partial: "shared/subscribe_form") }
    end
  end
end
