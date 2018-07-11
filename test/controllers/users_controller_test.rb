require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  test "should get confirm_email" do
    alice = users(:alice)
    get :confirm_email, params: { id: alice.confirm_token }
    assert_response :ok
    assert alice.reload.email_confirmed?
  end

  test "should fail to get confirm_email" do
    bob = users(:bob)
    get :confirm_email, params: { id: 'not_exist' }
    assert_response :precondition_failed
  end

  test "should fail to create aleady exist eos account" do
    alice = users(:alice)
    get :confirm_email, params: { id: alice.confirm_token }

    @controller.helpers.stub :eos_account_exist?, true do
      post :create_eos_account, params: { id: alice.confirm_token }, body: { account_name: 'chainpartner', pubkey: 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3' }.to_json, as: :json
      assert_response :conflict
    end
  end

  test "should success to create eos account" do
    class MockResponse
      def code
        200
      end

      def body
        JSON.parse(file_fixture('eos_create_account_response_success.json').read)
      end
    end

    @controller.helpers.stub :eos_account_exist?, false do
      @controller.helpers.stub :create_eos_account, MockResponse.new do
        alice = users(:alice)
        get :confirm_email, params: { id: alice.confirm_token }
    
        post :create_eos_account, params: { id: alice.confirm_token }, body: { account_name: 'chainpartner', pubkey: 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3' }.to_json, as: :json
        assert_response :ok
      end
    end
  end
end
