# == Schema Information
#
# Table name: settings
#
#  id                   :bigint(8)        not null, primary key
#  eosys_proxy_account  :string           not null
#  history_api_limit    :integer          not null
#  minimum_required_cpu :float            not null
#  minimum_required_net :float            not null
#  new_account_cpu      :float            not null
#  new_account_net      :float            not null
#  new_account_ram      :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
