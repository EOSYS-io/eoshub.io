class AddInitialPriceHistoryIntvls < ActiveRecord::Migration[5.2]
  def up
    # 1m, 3m, 5m, 15m, 30m, 1h, 4h, 1d, 1w.
    price_intvl_list_as_seconds = [
      60, 180, 300, 900, 1800, 3600, 14400, 86400, 604800
    ]

    price_intvl_list_as_seconds.each do | intvl | 
      PriceHistoryIntvl.create(seconds: intvl)
    end
  end

  def down
    PriceHistoryIntvl.delete_all
  end
end
