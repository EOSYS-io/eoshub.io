# == Schema Information
#
# Table name: users
#
#  id            :bigint(8)        not null, primary key
#  confirm_token :string(22)       default("")
#  email         :string
#  eos_account   :string           default(""), not null
#  state         :integer          default("email_saved")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_confirm_token  (confirm_token)
#  index_users_on_email          (email)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
