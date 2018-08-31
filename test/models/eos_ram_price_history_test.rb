# == Schema Information
#
# Table name: eos_ram_price_histories
#
#  close      :decimal(, )      not null
#  end_time   :datetime         not null
#  high       :decimal(, )      not null
#  intvl      :integer          not null
#  low        :decimal(, )      not null
#  open       :decimal(, )      not null
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
