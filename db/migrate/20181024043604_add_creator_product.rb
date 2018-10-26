class AddCreatorProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :creator_order, :string, default: '', comment: 'creator eos account when requested by order'
    add_column :products, :creator_event, :string, default: '', comment: 'creator eos account when requested by event'

    Product.eos_account.update(creator_order: 'eoshubwallet', creator_event: 'eoshubevent1')
  end
end
