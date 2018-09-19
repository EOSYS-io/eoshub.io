require 'test_helper'

class ProducersControllerTest < ActionDispatch::IntegrationTest
  fixtures :producers

  test "should get index" do
    get "/producers"
    
    expected_body = producers.to_json

    assert_match expected_body, @response.body
    assert_response :ok
  end
end
