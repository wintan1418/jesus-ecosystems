class Admin::SiteSettingsController < Admin::BaseController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  def index
    @settings = SiteSetting.order(:key)
  end

  def show; end

  def new
    @setting = SiteSetting.new
  end

  def create
    @setting = SiteSetting.new(setting_params)
    if @setting.save
      redirect_to admin_site_settings_path, notice: "Setting created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @setting.update(setting_params)
      redirect_to admin_site_settings_path, notice: "Setting saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @setting.destroy
    redirect_to admin_site_settings_path, notice: "Setting deleted."
  end

  private

  def set_setting
    @setting = SiteSetting.find(params[:id])
  end

  def setting_params
    params.require(:site_setting).permit(:key, :value)
  end
end
