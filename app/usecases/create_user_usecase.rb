class CreateUserUsecase
  class << self
    def perform(line_id, name)
      User.create(name:, line_id:)
    end
  end
end
