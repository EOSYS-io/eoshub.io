# == Schema Information
#
# Table name: payment_results
#
#  id               :bigint(8)        not null, primary key
#  cid              :string
#  code             :string           default("")
#  message          :string           default("")
#  pay_info         :string
#  tid              :string
#  transaction_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :bigint(8)        not null
#
# Indexes
#
#  index_payment_results_on_order_id  (order_id)
#

class PaymentResult < ApplicationRecord
  belongs_to :order

  validates :order, presence: true

  class << self
    def permit_attributes_on_create
      [:cid, :tid, :pay_info, :transaction_date, :code, :message]
    end
  end
end
