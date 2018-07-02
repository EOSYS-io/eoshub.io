require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should get confirm_email" do
    alice = users(:alice)
    get confirm_email_user_url(id: alice.confirm_token)
    assert_response :success
  end

  test "should fail to get confirm_email" do
    bob = users(:bob)
    get confirm_email_user_url(id: 'not_exist')
    assert_response :precondition_failed
  end
end
