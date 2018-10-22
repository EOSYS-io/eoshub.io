class AddCpuNetRamFieldToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :cpu, :float, default: 0
    add_column :products, :net, :float, default: 0
    add_column :products, :ram, :integer, default: 0
  end
end
