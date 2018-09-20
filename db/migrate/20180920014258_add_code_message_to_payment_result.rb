class AddCodeMessageToPaymentResult < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_results, :code, :string, default: ''
    add_column :payment_results, :message, :string, default: ''
  end
end
