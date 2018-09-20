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

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
