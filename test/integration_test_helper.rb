require "test_helper"
require "capybara/rails"

DatabaseCleaner.strategy = :truncation

class ActionDispatch:IntegrationTest
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