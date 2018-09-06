require 'test_helper'

class EosRamPriceHistoriesControllerTest < ActionController::TestCase
  fixtures :eos_ram_price_histories

  test "should fail with unsupported interval" do
    get :data, params: { intvl: 500, from: Time.now.to_i, to: Time.now.to_i + 50 }
    assert_response :bad_request
  end

  test "should success to retrieve data" do
    get :data, params: { 
      intvl: 60, 
      from: 1535948580, # 2018-09-03T04:23:00
      to: 1535948640 # 2018-09-03T04:24:00
    }

    expected_body = [
      eos_ram_price_histories(:interval_60_1),
      eos_ram_price_histories(:interval_60_2)
    ].to_json

    assert_match expected_body, @response.body
    assert_response :ok
  end
end
