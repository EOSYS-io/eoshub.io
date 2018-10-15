require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  fixtures :products

  test "should post request_payment" do
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

      def return_code
        :ok
      end
    end

    product = products(:one)

    @controller.stub :eos_account_exist?, false do
      mock_body = file_fixture('payletter_payment_request_response_success.json').read
      Typhoeus::Request.stub_any_instance :run, MockResponse.new(mock_body) do
        post :request_payment, body: { 
            pgcode: 'virtualaccount',
            eos_account: 'testtesttes1',
            product_id: product.id,
            public_key: 'EOS8MZzGSfAChnmBboTDtrm1n7axdutX8QMr855HyEKLwX3BuQ68A'
          }.to_json, as: :json
        assert_response :ok
      end
    end
  end
end
