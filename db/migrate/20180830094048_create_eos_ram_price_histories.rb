class CreateEosRamPriceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :eos_ram_price_histories do |t|
      t.integer :intvl, unsigned: true, null: false
      t.column :start_time, :timestamp, null: false
      t.column :end_time, :timestamp, null: false

      t.column :open, :decimal, precision: 38, scale: 8, null: false 
      t.column :close, :decimal, precision: 38, scale: 8, null: false
      t.column :high, :decimal, precision: 38, scale: 8, null: false
      t.column :low, :decimal, precision: 38, scale: 8, null: false

      t.timestamps
    end

    add_index :eos_ram_price_histories, [:intvl, :start_time], unique: true
  end
end
