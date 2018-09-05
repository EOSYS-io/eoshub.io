class CreatePriceHistoryIntvls < ActiveRecord::Migration[5.2]
  def change
    create_table :price_history_intvls, id: false do |t|
      t.integer :seconds, unsigned: true, primary_key: true
    end
  end
end
