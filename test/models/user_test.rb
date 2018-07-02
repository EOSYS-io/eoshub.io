# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  confirm_token   :string(22)       default("")
#  email           :string(255)      not null
#  email_confirmed :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
