class AddCountryToProducer < ActiveRecord::Migration[5.2]
  def change
    add_column :producers, :country, :string, default: ""
  end
end
