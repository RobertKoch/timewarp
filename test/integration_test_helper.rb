require "test_helper"
require "capybara/rails"

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  Capybara.default_driver = :webkit
  Capybara.default_wait_time = 3

  setup do
    Rails.cache.clear
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end
end

def login_admin(admin)
  visit new_admin_session_path

  fill_in "admin_email", :with => admin.email
  fill_in "admin_password", :with => admin.password
  click_on "Sign in"

  assert_equal admin_dashboard_path, current_path
end

def logout_admin(admin)
  assert page.has_content? "You are logged in as #{admin.email}"

  click_on 'logout_link'

  assert_equal new_admin_session_path, current_path
  assert page.has_no_content? "You are logged in as #{admin.email}"
end