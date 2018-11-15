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

class Announcement < ApplicationRecord
  validates :title_ko, presence: true
  validates :title_en, presence: true
  validates :title_cn, presence: true
  validates :body_ko, presence: true
  validates :body_en, presence: true
  validates :body_cn, presence: true
end
