class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  helper_method :current_admin

  # Admin URLs don't carry a locale prefix — keep URL helpers clean.
  def default_url_options
    {}
  end

  protected

  def set_locale
    I18n.locale = I18n.default_locale
  end
end
