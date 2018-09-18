# == Schema Information
#
# Table name: vote_stats
#
#  id                               :bigint(8)        not null, primary key
#  eosys_proxy_staked_account_count :integer          not null
#  eosys_proxy_staked_eos           :float            not null
#  total_staked_eos                 :float            not null
#  total_voted_eos                  :float            not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class VoteStat < ApplicationRecord
end
