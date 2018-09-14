# == Schema Information
#
# Table name: orders
#
#  id           :bigint(8)        not null, primary key
#  amount       :integer          not null
#  order_no     :string           not null
#  pgcode       :integer          default(NULL), not null
#  product_name :string           default("")
#  state        :integer          default("created"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint(8)
#
# Indexes
#
#  index_orders_on_order_no  (order_no)
#  index_orders_on_user_id   (user_id)
#

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
