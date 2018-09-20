class RemoveUniqueFromEosAccountOfOrder < ActiveRecord::Migration[5.2]
  def up
    remove_index :orders, :eos_account
    add_index :orders, :eos_account
  end

  def down
    remove_index :orders, :eos_account
    add_index :orders, :eos_account, unique: true
  end
end
