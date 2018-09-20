class AddEosAccountToOrder < ActiveRecord::Migration[5.2]
  def up
    add_column :orders, :eos_account, :string, null: false, default: ''
    Order.all.each {|order|
      order.update(eos_account: order.id)
    }
    add_index :orders, :eos_account, unique: true
    add_index :users, :eos_account, unique: true
  end

  def down
    remove_column :orders, :eos_account
    remove_index :users, :eos_account
  end
end
