class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.string :title_ko, null: false
      t.string :title_en, null: false
      t.string :title_cn, null: false
      t.text :body_ko, null: false
      t.text :body_en, null: false
      t.text :body_cn, null: false
      t.boolean :active, null: false, default: false
      t.datetime :published_at
      t.datetime :ended_at
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
