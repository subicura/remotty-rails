module Remotty::BaseApplicationController
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?
  end

  protected

  # paging - kaminari dependency
  def render_paging(items, options = nil)
    page = {
      json: items,
      meta_key: 'page',
      meta: {
        total_count: items.total_count,
        current_page: items.current_page,
        per_page: items.limit_value
      },
      root: 'items'
    }
    page.merge!(options) unless options.nil?

    render page
  end

  # error
  def render_error(code = 'ERROR', message = '', status = 400)
    render json: {
      error: {
        code: code,
        message: message
      }
    }, :status => status
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :avatar) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :avatar, :password, :password_confirmation, :current_password) }
  end

end
