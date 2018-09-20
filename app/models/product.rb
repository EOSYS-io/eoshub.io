# == Schema Information
#
# Table name: products
#
#  id         :bigint(8)        not null, primary key
#  active     :boolean          default(FALSE), not null
#  name       :string           not null
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_products_on_name  (name)
#

class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true
  validates :active, inclusion: { in: [true, false] }
end
