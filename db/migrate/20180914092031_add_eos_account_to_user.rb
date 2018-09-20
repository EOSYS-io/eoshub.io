class AddEosAccountToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :eos_account, :string, null: false, default: '', index: true
    User.all.each {|user|
      user.update(eos_account: user.id)
    }
    change_column :users, :eos_account, :string, unique: true
    change_column :users, :email, :string, null: true
  end

  def down
    remove_column :users, :eos_account
    change_column :users, :email, :string, null: false
  end
end
