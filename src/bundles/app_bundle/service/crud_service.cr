require "../service/crud_service"
require "../validator/validator"

module App
  abstract class CrudService(T)
    # def initialize(
    #   @repository : CrudRepository(T),
    #   @validator : Validator(T)
    # )
    # end

    def create(entity : T) : T
      @validator.validate!(entity)
      @repository.save(entity)
      entity
    end

    def update(entity : T) : T
      @validator.validate!(entity)
      @repository.save(entity)
      entity
    end

    def remove(id : String) : Void
      @repository.remove(id)
    end
  end
end
