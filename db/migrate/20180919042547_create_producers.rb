class CreateProducers < ActiveRecord::Migration[5.2]
  def change
    create_table :producers, id: false do |t|
      t.string :owner, primary_key: true
      t.float :total_votes, null: false
      t.string :producer_key, null: false
      t.integer :location, null: false
      t.string :url
      t.string :logo_image_url
      t.string :last_claim_time
      t.integer :unpaid_blocks, null: false

      t.boolean :is_active, default: true, null: false
      t.integer :rank, null: false
      t.integer :prev_rank, null: false

      t.timestamps
    end
  end
end
