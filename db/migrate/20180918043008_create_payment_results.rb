class CreatePaymentResults < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_results do |t|
      t.belongs_to :order, index: true, null: false
      t.string :tid
      t.string :cid
      t.string :pay_info
      t.datetime :transaction_date

      t.timestamps
    end
  end
end
