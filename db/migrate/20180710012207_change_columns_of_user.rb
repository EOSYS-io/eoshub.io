class ChangeColumnsOfUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :state, :integer, default: 0
    remove_column :users, :email_confirmed, :boolean
  end

  def down
    remove_column :users, :state, :integer
    add_column :users, :email_confirmed, :boolean, default: false
  end
end
