# == Schema Information
#
# Table name: users
#
#  id                       :bigint(8)        not null, primary key
#  confirm_token            :string(22)       default("")
#  confirm_token_created_at :datetime
#  email                    :string
#  eos_account              :string
#  ip_address               :string           default(""), not null
#  state                    :integer          default("email_saved")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_users_on_confirm_token  (confirm_token)
#  index_users_on_email          (email)
#  index_users_on_eos_account    (eos_account) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should return false for qualify_for_event" do
    (1..3).each do |i|
      User.create!(email: "test#{i}@test.net", state: :eos_account_created, eos_account: "testtesttes#{i}", ip_address: '1.1.1.1')
    end
    assert_not User.qualify_for_event('1.1.1.1')
  end

  test "should succeed to call has_valid_confirm_token" do
    alice = users(:alice)
    user = User.has_valid_confirm_token(alice.confirm_token)

    assert_equal user.id, alice.id
  end

  test "should return nil when call has_valid_confirm_token with blank confirm_token" do
    confirm_token = ""
    user = User.has_valid_confirm_token(confirm_token)

    assert_nil user
  end

  test "should return nil when call has_valid_confirm_token with old confirm_token" do
    user_has_old_confirm_token = users(:charlie)
    user = User.has_valid_confirm_token(user_has_old_confirm_token.confirm_token)

    assert_nil user
  end
end
