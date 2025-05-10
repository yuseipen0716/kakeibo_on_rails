# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  talk_mode  :integer          default("default_mode"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#  line_id    :text
#
# Indexes
#
#  index_users_on_group_id  (group_id)
#  index_users_on_line_id   (line_id) UNIQUE
#
# Foreign Keys
#
#  group_id  (group_id => groups.id)
#
FactoryBot.define do
  factory :user do
    name { "username" }
    line_id { SecureRandom.uuid }
  end
end
