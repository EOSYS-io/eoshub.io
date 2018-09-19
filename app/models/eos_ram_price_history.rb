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
  validates :start_time, presence: true, if: :is_correct_start_time?
  validates :end_time, presence: true, if: :is_correct_end_time?
  validates :high, presence: true, if: :is_correct_high?
  validates :low, presence: true, if: :is_correct_low?
  
   # A helper function for normalizing start time as a multiple of intvls.
  def floor_timestamp(intvl, timestamp) 
    return Time.at((timestamp.to_i/intvl).floor * intvl).to_datetime
  end

  def is_correct_start_time? 
    return floor_timestamp(intvl, start_time) == start_time
  end

  def is_correct_end_time?
    return (start_time.to_i + intvl) == end_time
  end

  def is_correct_high?
    return [open, close, high, low].max == high && high > 0
  end

  def is_correct_low?
    return [open, close, high, low].min == low && low > 0
  end

  def self.upsert_eos_ram_price_histories(price)
    intvls = PriceHistoryIntvl.all
    intvls.each do | intvl_record | 
      intvl = intvl_record.secondsz
      start = Time.at((Time.now.to_i/intvl).floor * intvl).to_datetime
      new_record = find_or_initialize_by(intvl: intvl, start_time: start) do | record |
        record.end_time = Time.at(start.to_i + intvl).to_datetime
        record.open = price
        record.close = price
        record.high = price
        record.low = price
      end

      new_record.update(
        close: price,
        high: [record.high, price].max,
        low: [record.low, price].min
      )
    end
  end
end
