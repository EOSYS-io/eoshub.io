class RemoveUserIdFromOrder < ActiveRecord::Migration[5.2]
  def up
    remove_column :orders, :user_id
  end

  def down
    add_reference :orders, :user
  end
end
