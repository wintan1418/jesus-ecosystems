class Admin::EmailSubscribersController < Admin::BaseController
  def index
    scope = EmailSubscriber.order(created_at: :desc)
    scope = scope.where(locale: params[:locale]) if params[:locale].present?

    if params[:q].present?
      scope = scope.where("email ILIKE :q OR first_name ILIKE :q", q: "%#{params[:q]}%")
    end

    @subscribers = scope.limit(200)
  end

  def show
    @subscriber = EmailSubscriber.find(params[:id])
  end

  def destroy
    EmailSubscriber.find(params[:id]).destroy
    redirect_to admin_email_subscribers_path, notice: "Subscriber removed."
  end
end
