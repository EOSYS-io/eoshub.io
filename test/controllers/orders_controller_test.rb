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

    product = products(:eos_account)

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

  test "should post orders" do
    order_one = orders(:one)

    return_params = file_fixture('payletter_payment_return_params_succeeded.json').read
    post :create, body: return_params, as: :json
    
    assert_redirected_to order_path(order_one.order_no)
    
    expected = JSON.parse(return_params)
    assert_equal expected.dig('issue_tid'), Order.last.tid
  end
end
