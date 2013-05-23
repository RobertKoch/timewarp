class SessionsController < Devise::SessionsController
  protected
  def after_sign_in_path_for(resource_or_scope)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_admin_session_path
  end
end