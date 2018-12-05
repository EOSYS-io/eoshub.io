# == Schema Information
#
# Table name: announcements
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(FALSE), not null
#  body_cn      :text             not null
#  body_en      :text             not null
#  body_ko      :text             not null
#  ended_at     :datetime
#  published_at :datetime
#  title_cn     :string           not null
#  title_en     :string           not null
#  title_ko     :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
