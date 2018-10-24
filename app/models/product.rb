# == Schema Information
#
# Table name: products
#
#  id                                                         :bigint(8)        not null, primary key
#  active                                                     :boolean          default(FALSE), not null
#  cpu                                                        :float            default(0.0)
#  creator_event(creator eos account when requested by event) :string           default("")
#  creator_order(creator eos account when requested by order) :string           default("")
#  event_activation                                           :boolean          default(FALSE), not null
#  name                                                       :string           not null
#  net                                                        :float            default(0.0)
#  price                                                      :integer          not null
#  ram                                                        :integer          default(0)
#  created_at                                                 :datetime         not null
#  updated_at                                                 :datetime         not null
#
# Indexes
#
#  index_products_on_name  (name)
#

class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true
  validates :active, inclusion: { in: [true, false] }

  scope :eos_account, -> { where(name: 'EOS Account').where(active: true).take }

  def as_json(*args)
    { id: id, active: active, name: name, price: price, event_activation: event_activation, cpu: cpu, net: net, ram: ram }
  end
end
