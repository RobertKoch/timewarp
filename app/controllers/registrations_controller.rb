class RegistrationsController < Devise::RegistrationsController
  before_filter :redirect_not_allowed
  def new
  end

  private
  def redirect_not_allowed
    redirect_to new_admin_session_path if !current_admin
  end
end
