class AddConfirmTokenCreatedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :confirm_token_created_at, :datetime
  end
end
