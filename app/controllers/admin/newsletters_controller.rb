class Admin::NewslettersController < Admin::BaseController
  before_action :set_newsletter, only: [:show, :edit, :update, :destroy, :send_test, :broadcast]

  def index
    @drafts = Newsletter.draft.recent.limit(50)
    @sent   = Newsletter.sent.recent.limit(50)
  end

  def show; end

  def new
    @newsletter = Newsletter.new(locale: "en")
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)
    if @newsletter.save
      redirect_to admin_newsletter_path(@newsletter), notice: "Draft saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @newsletter.update(newsletter_params)
      redirect_to admin_newsletter_path(@newsletter), notice: "Draft updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @newsletter.sent?
      redirect_to admin_newsletter_path(@newsletter), alert: "Already sent — cannot delete."
    else
      @newsletter.destroy
      redirect_to admin_newsletters_path, notice: "Draft deleted."
    end
  end

  # Send a test copy to the current admin's email address only.
  def send_test
    NewsletterMailer.test(@newsletter, current_admin.email).deliver_now
    redirect_to admin_newsletter_path(@newsletter),
                notice: "Test sent to #{current_admin.email}."
  rescue => e
    redirect_to admin_newsletter_path(@newsletter),
                alert: "Test failed: #{e.message}"
  end

  # Broadcast to every confirmed subscriber in the locale. Marks sent_at on
  # completion so it can't be sent twice.
  def broadcast
    if @newsletter.sent?
      redirect_to admin_newsletter_path(@newsletter), alert: "Already sent." and return
    end

    @newsletter.update!(sent_by: current_admin)
    NewsletterBroadcastJob.perform_later(@newsletter.id)

    redirect_to admin_newsletter_path(@newsletter),
                notice: "Broadcast queued — #{@newsletter.recipients.count} subscribers will receive it."
  end

  private

  def set_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :preheader, :locale, :scheduled_for, :body)
  end
end
