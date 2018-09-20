require 'test_helper'

class PaymentResultsControllerTest < ActionController::TestCase
  fixtures :orders

  test "should create succeeded payment_result and change the order's state to paid" do
    order_one = orders(:one)

    callback_params = file_fixture('payletter_payment_return_params_succeeded.json').read
    post :create, body: callback_params, as: :json
    
    assert_response :ok
    
    assert order_one.reload.paid?

    expected = JSON.parse(callback_params)
    assert_equal expected.dig('cid'), PaymentResult.last.cid
    assert_equal expected.dig('tid'), PaymentResult.last.tid
    assert_equal expected.dig('pay_info'), PaymentResult.last.pay_info
  end

  test "should create failed payment_result and the order's state should be created state" do
    order_one = orders(:one)

    callback_params = file_fixture('payletter_payment_return_params_failed.json').read
    post :create, body: callback_params, as: :json
    
    assert_response :ok
    
    assert order_one.reload.created?

    expected = JSON.parse(callback_params)
    assert_equal order_one.id, PaymentResult.last.order_id
    assert_equal expected.dig('code'), PaymentResult.last.code
    assert_equal expected.dig('message'), PaymentResult.last.message
  end
end
