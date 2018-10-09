class AddIpAddressToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ip_address, :string, null: false, default: ''
  end
end
