# == Schema Information
#
# Table name: orders
#
#  id                                                                 :bigint(8)        not null, primary key
#  account_name(the name of the payer who issued the virtual account) :string
#  account_no(virtual account number)                                 :string           default("")
#  amount                                                             :integer          not null
#  bank_code(Virtual account bank code)                               :string
#  bank_name(Virtual account bank name)                               :string
#  eos_account                                                        :string           default(""), not null
#  expire_date(expiration date of the virtual account)                :date
#  order_no                                                           :string           not null
#  pgcode                                                             :integer          default(NULL), not null
#  product_name                                                       :string           default("")
#  state                                                              :integer          default("created"), not null
#  created_at                                                         :datetime         not null
#  updated_at                                                         :datetime         not null
#  user_id                                                            :bigint(8)
#
# Indexes
#
#  index_orders_on_eos_account  (eos_account) UNIQUE
#  index_orders_on_order_no     (order_no)
#  index_orders_on_user_id      (user_id)
#

class Order < ApplicationRecord
  include AASM

  belongs_to :user

  validates :eos_account, uniqueness: true

  # using only virtual_account
  enum pgcode: {
    # creditcard	신용카드
    # kftc	인터넷뱅킹(금융결제원)
    # inibank	인터넷뱅킹(이니시스)
    virtualaccount: 3	#가상계좌
    # mobile	휴대폰
    # book	도서상품권
    # culture	문화상품권
    # smartculture	스마트문상
    # happymoney	해피머니상품권
    # mobilepop	모바일팝
    # teencash	틴캐시
    # tmoney	교통카드결제
    # cvs	편의점캐시
    # eggmoney	에그머니
    # oncash	온캐시
    # phonebill	폰빌
    # cashbee	캐시비
  }

  # using only single payment
  enum paymethod: {
    single: 1,            #단건
    # regular_automatic: 2, #정기자동결제
    # hand: 3               #수기결제
  }

  enum state: {
    created: 0,
    paid: 1
  }

  aasm column: :state, enum: true do
    state :created, initial: true
    state :paid

    event :paid do
      transitions from: :created, to: :paid
    end
  end

  class << self
    def permit_attributes_on_create
      [:user_id, :order_no, :pgcode, :amount, :product_name, :account_name, :account_no, :bank_code, :bank_name, :expire_date]
    end

    def generate_order_no
      order_no = nil

      loop do
        order_no = (0..9).to_a.shuffle[0, 8].join
        break unless self.where(order_no: order_no).exists?
      end

      order_no
    end
  end
end
