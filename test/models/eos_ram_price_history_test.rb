# == Schema Information
#
# Table name: eos_ram_price_histories
#
#  close      :decimal(38, 8)   not null
#  end_time   :datetime         not null
#  high       :decimal(38, 8)   not null
#  intvl      :integer          not null
#  low        :decimal(38, 8)   not null
#  open       :decimal(38, 8)   not null
#  start_time :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class EosRamPriceHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
