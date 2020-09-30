require "glassy-mongo-odm"

module App
  abstract class CrudRepository(T) < Glassy::MongoODM::Repository(T)
  end
end
