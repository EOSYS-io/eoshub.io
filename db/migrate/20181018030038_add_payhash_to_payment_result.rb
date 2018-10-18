class AddPayhashToPaymentResult < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_results, :payhash, :string, default: ''
    add_column :payment_results, :user_id, :string, default: ''
    add_column :payment_results, :amount, :string, default: ''
  end
end
