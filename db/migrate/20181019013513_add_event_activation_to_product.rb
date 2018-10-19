class AddEventActivationToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :event_activation, :boolean, default: false, null: false
  end
end
