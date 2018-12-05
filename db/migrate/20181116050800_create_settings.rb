class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.float :new_account_cpu, null: false
      t.float :new_account_net, null: false
      t.integer :new_account_ram, null: false
      t.float :minimum_required_cpu, null: false
      t.float :minimum_required_net, null: false
      t.integer :history_api_limit, null: false
      t.string :eosys_proxy_account, null: false

      t.timestamps
    end
  end
end
