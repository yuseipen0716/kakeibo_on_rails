# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  talk_mode  :integer          default(0), not null
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
class User < ApplicationRecord
  belongs_to :group, optional: true
  has_many :expense_records

  enum talk_mode: {
    default: 0,
    input: 1,
    show: 2,
    group: 3
  }
end
