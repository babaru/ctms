class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :image])
  end

  def get_redirect_url_from_session
    @redirect_url = session[:redirect_url]
    session[:redirect_url] = nil
  end

  def set_redirect_url_to_session
    session[:redirect_url] = params[:redirect_url]
  end

  def get_redirect_url_from_params
    @redirect_url = params[:redirect_url]
  end

  def redirect_url
    @redirect_url
  end
end
