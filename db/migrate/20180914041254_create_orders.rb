class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.belongs_to :user, index: true, null: true
      t.integer :state, default: 0, null: false
      t.integer :pgcode, default: 0, null: false
      t.string :order_no, null: false, index: true
      t.integer :amount, null: false
      t.string :product_name, default: ''
      
      t.timestamps
    end
  end
end
