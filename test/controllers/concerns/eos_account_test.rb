require 'test_helper'

class EosAccountFakeController < ActionController::Base
  include EosAccount
end

class EosAccountFakeControllerTest < ActionController::TestCase
  test "beautyofcode account exist" do
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

    mock_body = file_fixture('eos_get_account_response_success.json').read
    Typhoeus::Request.stub_any_instance :run, MockResponse.new(mock_body) do
      assert @controller.eos_account_exist?('beautyofcode')
    end
  end

  test "beautyofcode account non exist" do
    class MockResponse
      def initialize(mock_body)
        @mock_body = mock_body
      end

      def code
        500
      end

      def body
        @mock_body
      end
    end

    mock_body = file_fixture('eos_get_account_response_not_exist.json').read
    Typhoeus::Request.stub_any_instance :run, MockResponse.new(mock_body) do
      assert_not @controller.eos_account_exist?('beautyofcode')
    end
  end

  test "should fail to create already exist eos account" do
    class MockResponse
      def initialize(mock_body)
        @mock_body = mock_body
      end

      def code
        500
      end

      def body
        @mock_body
      end
    end

    account_name = 'chainpartner'
    pubkey = 'EOS5x2nWYYncpQ6h3dz9QEjBBisSPymX1fkyguJUv6bGkZfr5Uvx3'

    mock_body = file_fixture('eos_create_account_response_already_exist.json').read
    Typhoeus::Request.stub_any_instance :run, MockResponse.new(mock_body) do
      creator_eos_account = Rails.application.credentials.dig(:creator_eos_account_order)
      response = @controller.request_eos_account_creation(creator_eos_account, account_name, pubkey)
      assert_equal 500, response.code
    end
  end
end
