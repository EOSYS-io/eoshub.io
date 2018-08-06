class AddConfirmableToDevise < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :confirmation_token, :string
    add_column :admin_users, :confirmed_at, :datetime
    add_column :admin_users, :confirmation_sent_at, :datetime
    add_index :admin_users, :confirmation_token, unique: true
    AdminUser.all.update_all confirmed_at: DateTime.now
  end

  def down
    remove_columns :admin_users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
