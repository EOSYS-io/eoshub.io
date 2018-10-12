class AddPublicKeyToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :public_key, :string, null: false, default: ''
  end
end
