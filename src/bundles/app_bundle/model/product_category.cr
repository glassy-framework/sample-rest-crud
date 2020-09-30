require "glassy-mongo-odm"

module App
  include Glassy::MongoODM::Annotations

  @[ODM::Document]
  class ProductCategory
    @[ODM::Id]
    property id : BSON::ObjectId?

    @[ODM::Field]
    property name : String

    @[ODM::Field]
    property old_id : Int32?

    @[ODM::Initialize]
    def initialize(@name)
    end
  end
end
