class AddDeliveryMessageToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :delivery_message, :jsonb, default: {}
  end
end
