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
class User < ApplicationRecord
  belongs_to :group, optional: true
  has_many :expense_records

  enum talk_mode: {
    default_mode: 0,
    input_mode: 1,
    show_mode: 2,
    group_mode: 3,
    expense_input_mode: 4,
    income_input_mode: 5,
    group_creating_mode: 6,
    group_joining_mode: 7
  }
end
