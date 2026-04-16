class FreeCopyRequestsController < ApplicationController
  # Form parameter that should always be empty — bots fill it, humans never see it.
  HONEYPOT_FIELD = :company_website

  def new
    @request = FreeCopyRequest.new(locale: I18n.locale.to_s, status: "pending",
                                   qty_vol_1: 0, qty_vol_1_combo: 0)
    set_meta_tags title:       I18n.t("free_copy.new.heading_1") + " " + I18n.t("free_copy.new.heading_2"),
                  description: I18n.t("free_copy.new.subhead")
  end

  def create
    # Honeypot — bots fill it, humans don't. Pretend success and bail.
    if params[HONEYPOT_FIELD].present?
      redirect_to free_copy_thank_you_path and return
    end

    @request = FreeCopyRequest.new(request_params.merge(
      locale:     I18n.locale.to_s,
      status:     "pending",
      ip_address: request.remote_ip
    ))

    if @request.save
      FreeCopyMailer.confirmation(@request).deliver_later if @request.email.present?
      FreeCopyMailer.admin_notification(@request).deliver_later
      redirect_to free_copy_thank_you_path,
                  notice: "Your request is in. We'll get the books out to you."
    else
      flash.now[:alert] = "Some fields need fixing — see below."
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you; end

  private

  def request_params
    params.require(:free_copy_request).permit(
      :first_name, :last_name, :email, :phone,
      :address_line_1, :address_line_2, :city, :state_province,
      :postal_code, :country, :notes,
      :qty_vol_1, :qty_vol_1_combo
    )
  end
end
