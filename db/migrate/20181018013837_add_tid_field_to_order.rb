class AddTidFieldToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :tid, :string, default: ''
  end
end
