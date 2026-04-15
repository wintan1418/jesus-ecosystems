class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :set_locale

  helper_method :available_locales

  protected

  # URL is the single source of truth. The bare-root redirect handles first
  # visits via Accept-Language, but once you're on /en, /es, or /pt, the URL
  # decides — no cookie shadowing.
  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def available_locales
    I18n.available_locales
  end

  # After admin sign-in, land on the Avo dashboard instead of the site root.
  def after_sign_in_path_for(resource)
    resource.is_a?(Admin) ? "/avo" : super
  end

  # After admin sign-out, bounce back to the sign-in page.
  def after_sign_out_path_for(resource_or_scope)
    resource_or_scope == :admin ? new_admin_session_path : super
  end

  private

  def extract_locale
    parsed = params[:locale].to_s
    parsed.presence_in(I18n.available_locales.map(&:to_s))
  end
end
