require 'test_helper'

class VoteStatsControllerTest < ActionController::TestCase
  fixtures :vote_stats

  test "should get recent stat" do
    get :recent_stat

    expected_body = vote_stats(:recent_stat).to_json

    assert_match expected_body, @response.body
    assert_response :ok
  end

  test "should fail with not found" do
    VoteStat.delete_all
    get :recent_stat
    assert_response :not_found
  end
end
