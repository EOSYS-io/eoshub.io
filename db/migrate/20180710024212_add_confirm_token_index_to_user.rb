class AddConfirmTokenIndexToUser < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :confirm_token
  end
end
