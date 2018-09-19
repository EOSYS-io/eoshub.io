# == Schema Information
#
# Table name: producers
#
#  country         :string           default("")
#  is_active       :boolean          default(TRUE), not null
#  last_claim_time :string
#  location        :integer          not null
#  logo_image_url  :string
#  owner           :string           not null, primary key
#  prev_rank       :integer          not null
#  producer_key    :string           not null
#  rank            :integer          not null
#  total_votes     :float            not null
#  unpaid_blocks   :integer          not null
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Producer < ApplicationRecord
end
