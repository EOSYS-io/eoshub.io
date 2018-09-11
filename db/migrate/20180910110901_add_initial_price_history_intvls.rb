class AddInitialPriceHistoryIntvls < ActiveRecord::Migration[5.2]
  def up
    # 1m, 3m, 5m, 15m, 30m, 1h, 4h, 1d, 1w.
    price_intvl_list_as_seconds = [
      { seconds: 60 },
      { seconds: 180 },
      { seconds: 300 },
      { seconds: 900 },
      { seconds: 1800 },
      { seconds: 3600 },
      { seconds: 14400 },
      { seconds: 86400 },
      { seconds: 604800 }
    ]

    PriceHistoryIntvl.create(price_intvl_list_as_seconds)
  end

  def down
    PriceHistoryIntvl.delete_all
  end
end
