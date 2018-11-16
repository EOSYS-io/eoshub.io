# == Schema Information
#
# Table name: settings
#
#  id                   :bigint(8)        not null, primary key
#  eosys_proxy_account  :string           not null
#  history_api_limit    :integer          not null
#  minimum_required_cpu :float            not null
#  minimum_required_net :float            not null
#  new_account_cpu      :float            not null
#  new_account_net      :float            not null
#  new_account_ram      :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Setting < ApplicationRecord
  validates :new_account_cpu, presence: true
  validates :new_account_net, presence: true
  validates :new_account_ram, presence: true
  validates :minimum_required_cpu, presence: true
  validates :minimum_required_net, presence: true
  validates :history_api_limit, presence: true
  validates :eosys_proxy_account, presence: true
end
