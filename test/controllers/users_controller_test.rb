require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  test "should post confirm_email" do
    alice = users(:alice)
    post :confirm_email, params: { id: alice.confirm_token }
    
    assert_response :ok
    
    expect_body = { message: I18n.t('users.email_confirmed') }.to_json
    assert_equal expect_body, @response.body
    
    assert alice.reload.email_confirmed?
  end

  test "should fail to post confirm_email" do
    bob = users(:bob)
    post :confirm_email, params: { id: 'not_exist' }
    
    assert_response :bad_request
    expect_body = { message: I18n.t('users.invalid_email_confirm_token') }.to_json
    assert_equal expect_body, @response.body
  end

  test "should fail to create aleady exist eos account" do
    alice = users(:alice)
    post :confirm_email, params: { id: alice.confirm_token }

    @controller.stub :eos_account_exist?, true do
      post :create_eos_account, params: { id: alice.confirm_token }, body: { account_name: 'chainpartner', pubkey: 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3' }.to_json, as: :json
      assert_response :conflict
    end
  end

  test "should success to create eos account" do
    class MockResponse
      def initialize(mock_body)
        @mock_body = mock_body
      end

      def code
        200
      end

      def body
        @mock_body
      end
    end

    @controller.stub :eos_account_exist?, false do
      mock_body = file_fixture('eos_create_account_response_success.json').read
      @controller.stub :request_eos_account_creation, MockResponse.new(mock_body) do
        alice = users(:alice)
        post :confirm_email, params: { id: alice.confirm_token }
    
        creator_eos_account = Rails.application.credentials.dig(:creator_eos_account_event)
        eos_account = 'chainpartner'
        body = {
          creator_eos_account: creator_eos_account,
          account_name: eos_account,
          pubkey: 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3'
        }
        post :create_eos_account, params: { id: alice.confirm_token }, body: body.to_json, as: :json
        assert_response :ok

        assert_equal alice.reload.eos_account, eos_account
      end
    end
  end
end
