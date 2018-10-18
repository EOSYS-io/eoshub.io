require 'test_helper'

class PaymentResultsControllerTest < ActionController::TestCase
  fixtures :orders

  test "should create succeeded payment_result and change the order's state to paid" do
    order_one = orders(:one)

    callback_params = file_fixture('payletter_payment_callback_params_succeeded.json').read
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

    callback_params = file_fixture('payletter_payment_callback_params_failed.json').read
    post :create, body: callback_params, as: :json
    
    assert_response :ok
    
    assert order_one.reload.created?

    expected = JSON.parse(callback_params)
    assert_equal order_one.id, PaymentResult.last.order_id
    assert_equal expected.dig('code'), PaymentResult.last.code
    assert_equal expected.dig('message'), PaymentResult.last.message
  end

  test "should get valid sha256 hash" do
    user_id = 'eosyskoreabp'
    amount = 3000
    tid = 'eosys-201810163524840'

    hash = @controller.sha256_hash(user_id, amount, tid)
    expected_hash = 'AB25BBCEED2206F5C2C60503C0074EC1FA699DA69B8829FC9A3ADAF0294E439C'

    assert_equal hash, expected_hash
  end
end
