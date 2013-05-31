# -*- encoding : utf-8 -*-
require "integration_test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  setup do
    @site = FactoryGirl.build(:empty_site)
  end

  test "user should see a form to enter a url" do
    visit root_path

    assert page.has_content? "früher war alles besser! auch das web-design?"

    assert page.find("#new_site").visible?
    assert page.find_field("site_url").visible?
    assert page.find_button("warp !").visible?
  end

  test "user should see a explenation" do
    visit root_path

    assert page.has_content? "früher war alles besser! auch das web-design?"
    assert page.find("#instructions").visible?
  end
  
  test "user should see a user-navigation" do
    visit root_path

    assert page.has_content? "früher war alles besser! auch das web-design?"

    assert page.find("#navigation").visible?
    assert page.has_link? "timewarp"
    assert page.has_link? "archiv"
    assert page.has_link? "geschichte"
    assert page.has_link? "team"
  end
  
  test "admin should see a admin-navigation" do
    @admin = FactoryGirl.create(:admin)
    
    login_admin @admin
    
    visit root_path

    assert_equal root_path, current_path
    assert page.has_content? "You are logged in as #{@admin.email}"
    assert page.find("#navigation").visible?
    assert page.has_link? "dashboard"
    assert page.has_link? "sites"
    assert page.has_link? "admins"
    assert page.has_link? "logout"

    logout_admin @admin
  end
end