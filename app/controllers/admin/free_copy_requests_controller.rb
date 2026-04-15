class Admin::FreeCopyRequestsController < Admin::BaseController
  before_action :set_request, only: [:show, :edit, :update, :destroy, :update_status]

  def index
    scope = FreeCopyRequest.recent

    if params[:status].present?
      scope = scope.where(status: params[:status])
    end

    if params[:q].present?
      q = "%#{params[:q]}%"
      scope = scope.where(
        "email ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q OR city ILIKE :q OR country ILIKE :q",
        q: q
      )
    end

    @requests = scope.limit(100)
    @counts   = FreeCopyRequest.group(:status).count
  end

  def show; end

  def new
    @request = FreeCopyRequest.new(status: "pending", locale: "en")
  end

  def create
    @request = FreeCopyRequest.new(request_params)
    if @request.save
      redirect_to admin_free_copy_request_path(@request), notice: "Request created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @request.update(request_params)
      redirect_to admin_free_copy_request_path(@request), notice: "Request updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    new_status = params[:status].to_s
    if FreeCopyRequest::STATUSES.include?(new_status) && @request.update(status: new_status)
      redirect_to admin_free_copy_request_path(@request), notice: "Marked as #{new_status}."
    else
      redirect_to admin_free_copy_request_path(@request), alert: "Could not update status."
    end
  end

  def destroy
    @request.destroy
    redirect_to admin_free_copy_requests_path, notice: "Request deleted."
  end

  def bulk_ship
    ids = Array(params[:ids])
    count = FreeCopyRequest.where(id: ids).update_all(status: "shipped", updated_at: Time.current)
    redirect_to admin_free_copy_requests_path, notice: "Shipped #{count} request#{'s' unless count == 1}."
  end

  private

  def set_request
    @request = FreeCopyRequest.find(params[:id])
  end

  def request_params
    params.require(:free_copy_request).permit(
      :first_name, :last_name, :email, :phone,
      :address_line_1, :address_line_2, :city, :state_province,
      :postal_code, :country, :locale, :status, :notes,
      volumes_requested: []
    )
  end
end
