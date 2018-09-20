class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name, null: false, index: true
      t.integer :price, null: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end

    Product.create!(name: 'EOS Account', price: 3000, active: false)
  end
end
