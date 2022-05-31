class ApplicationController < ActionController::Base
  add_flash_types :danger
  before_action :require_login

  private

  def not_authenticated
    flash[:danger] = 'ログインしてください'
    redirect_to main_app.login_path
  end
end
