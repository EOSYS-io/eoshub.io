class ChangeNullOfEosAccount < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :eos_account, :string, null: true, default: nil
  end
end
