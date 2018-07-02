class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: true, limit: 255
      t.boolean :email_confirmed, default: false
      t.string :confirm_token, limit: 22

      t.timestamps
    end
  end
end
