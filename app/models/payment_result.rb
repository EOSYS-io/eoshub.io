# == Schema Information
#
# Table name: payment_results
#
#  id               :bigint(8)        not null, primary key
#  amount           :string           default("")
#  cid              :string
#  code             :string           default("")
#  message          :string           default("")
#  pay_info         :string
#  payhash          :string           default("")
#  tid              :string
#  transaction_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :bigint(8)        not null
#  user_id          :string           default("")
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
      [:user_id, :amount, :cid, :tid, :pay_info, :transaction_date, :code, :message, :payhash]
    end
  end
end
