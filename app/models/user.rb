# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          not null
#  line_id    :text
#
# Indexes
#
#  index_users_on_group_id  (group_id)
#
# Foreign Keys
#
#  group_id  (group_id => groups.id)
#
class User < ApplicationRecord
  belongs_to :group
  has_many :expense_records
end
