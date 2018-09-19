# TODO(heejae): Implement tests for helper functions.
module EosRamPriceHistoriesHelper
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
end
