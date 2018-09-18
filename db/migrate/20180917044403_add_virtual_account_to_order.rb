class AddVirtualAccountToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :account_no, :string, default: "", comment: 'virtual account number'
    add_column :orders, :account_name, :string, comment: 'the name of the payer who issued the virtual account'
    add_column :orders, :bank_code, :string, comment: 'Virtual account bank code'
    add_column :orders, :bank_name, :string, comment: 'Virtual account bank name'
    add_column :orders, :expire_date, :date, comment: 'expiration date of the virtual account'
  end
end
