require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get confirm_email" do
    get users_confirm_email_url
    assert_response :success
  end

end
