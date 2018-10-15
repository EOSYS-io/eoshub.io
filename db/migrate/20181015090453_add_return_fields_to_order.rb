class AddReturnFieldsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :return_code, :string, default: ''
    add_column :orders, :return_message, :string, default: ''
  end
end
