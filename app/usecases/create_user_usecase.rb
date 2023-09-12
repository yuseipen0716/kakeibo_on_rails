class CreateUserUsecase
  class << self
    def perform(line_id, name)
      User.create!(name: name, line_id: line_id)
    end
  end
end
