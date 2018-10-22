class AddCpuNetRamFieldToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :cpu, :float, default: 0
    add_column :products, :net, :float, default: 0
    add_column :products, :ram, :integer, default: 0

    Product.eos_account.update(cpu: 0.1, net: 0.01, ram: 3072)
  end
end
