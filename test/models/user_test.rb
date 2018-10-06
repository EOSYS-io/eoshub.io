# == Schema Information
#
# Table name: users
#
#  id            :bigint(8)        not null, primary key
#  confirm_token :string(22)       default("")
#  email         :string
#  eos_account   :string
#  state         :integer          default("email_saved")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_confirm_token  (confirm_token)
#  index_users_on_email          (email)
#  index_users_on_eos_account    (eos_account) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "eos_account_created!" do
    alice = users(:alice)
    assert_equal alice.eos_account, nil

    eos_account = 'testtesttest'
    alice.eos_account_created!(eos_account)
    assert_equal alice.eos_account, eos_account
  end
end
