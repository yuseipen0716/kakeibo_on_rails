# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Group < ApplicationRecord
  has_many :users
end
