require "jsonapi-serializer-cr"
require "../service/storage_service"
require "../exception/validation_exception"

module App
  class PublicUrlSerializer
    include JSONApiSerializer::Serializer(String)

    def initialize(@storage_service : StorageService)
    end

    def serialize(path : String?) : String?
      if path.nil?
        "null"
      else
        @storage_service.public_url(path.not_nil!).to_json
      end
    end

    def deserialize(value : JSON::Any, base : String? = nil) : String?
      raise ValidationException.new("ReadOnly Attribute")
    end
  end
end
