require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  fixtures :products

  test "should get EOS Account product" do
    eos_account_product = products(:eos_account)

    get eos_account_products_url
    
    assert_response :ok
    
    result_product = JSON.parse(@response.body)
    assert_equal result_product.symbolize_keys, eos_account_product.reload.as_json
  end
end
