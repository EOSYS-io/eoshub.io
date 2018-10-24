# == Schema Information
#
# Table name: products
#
#  id               :bigint(8)        not null, primary key
#  active           :boolean          default(FALSE), not null
#  cpu              :float            default(0.0)
#  event_activation :boolean          default(FALSE), not null
#  name             :string           not null
#  net              :float            default(0.0)
#  price            :integer          not null
#  ram              :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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
