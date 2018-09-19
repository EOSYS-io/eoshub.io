require 'test_helper'

class PaymentResultsControllerTest < ActionController::TestCase
  fixtures :orders

  test "should create payment_result and change the order's state to paid" do
    order_one = orders(:one)

    callback_params = file_fixture('payletter_payment_return_params.json').read
    post :create, body: callback_params, as: :json
    
    assert_response :ok
    
    assert order_one.reload.paid?

    expected = JSON.parse(callback_params)
    assert_equal expected.dig('cid'), PaymentResult.last.cid
    assert_equal expected.dig('tid'), PaymentResult.last.tid
    assert_equal expected.dig('pay_info'), PaymentResult.last.pay_info
  end
end
