# == Schema Information
#
# Table name: eos_ram_price_histories
#
#  id         :bigint(8)        not null, primary key
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
# Indexes
#
#  index_eos_ram_price_histories_on_intvl_and_start_time  (intvl,start_time) UNIQUE
#

require 'test_helper'

class EosRamPriceHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
