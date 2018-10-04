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

class EosRamPriceHistory < ApplicationRecord
  include EosRamPriceHistoriesHelper

  validates :start_time, presence: true, if: :is_correct_start_time?
  validates :end_time, presence: true, if: :is_correct_end_time?
  validates :high, presence: true, if: :is_correct_high?
  validates :low, presence: true, if: :is_correct_low?

  def self.upsert_eos_ram_price_histories(price)
    intvls = PriceHistoryIntvl.all
    intvls.each do | intvl_record | 
      intvl = intvl_record.seconds
      start = Time.at((Time.now.to_i/intvl).floor * intvl).to_datetime
      begin
        new_record = find_or_initialize_by(intvl: intvl, start_time: start) do | record |
          record.end_time = Time.at(start.to_i + intvl).to_datetime
          record.open = price
          record.close = price
          record.high = price
          record.low = price
        end

        new_record.update(
          close: price,
          high: [new_record.high, price].max,
          low: [new_record.low, price].min
        )
      rescue ActiveRecord::RecordNotUnique
        # This case can happen in multithreaded environment when active record cannot sync with database.
        existing_record = where({ intvl: intvl, start_time: start}).first
        existing_record.update(
          close: price,
          high: [new_record.high, price].max,
          low: [new_record.low, price].min
        )
        # As it is already inserted, do nothing.
      end
    end
  end
end
