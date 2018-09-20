class CreateVoteStats < ActiveRecord::Migration[5.2]
  def change
    create_table :vote_stats do |t|
      t.float :total_voted_eos, null: false
      t.float :total_staked_eos, null: false
      t.float :eosys_proxy_staked_eos, null: false
      t.integer :eosys_proxy_staked_account_count, null: false 

      t.timestamps
    end
  end
end
