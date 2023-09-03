class User < ApplicationRecord
  belongs_to :group
  has_many :expense_records
end
