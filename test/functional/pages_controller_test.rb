require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get imprint" do
    get :imprint
    assert_response :success
  end

  test "should get general_terms" do
    get :general_terms
    assert_response :success
  end

end
