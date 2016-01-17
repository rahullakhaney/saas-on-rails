class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_mailer_host

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => exception.message
  end

  protected

  def authenticate_inviter!
    unless current_user.has_role? :app_admin
      redirect_to root_url, :notice => "You are not authorized to access this page"
      return
    end
    super
  end

  def set_mailer_host
  	ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def configure_permitted_parameters
  	devise_parameter_sanitizer.for(:sign_up) << :subdomain
    devise_parameter_sanitizer.for(:invite) << :subdomain
  end

end
