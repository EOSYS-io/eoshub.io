class AddDefaultToConfirmToken < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :confirm_token, ''
  end
end
