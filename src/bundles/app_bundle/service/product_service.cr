require "./crud_service"
require "../repository/product_repository"
require "../validator/product_validator"
require "./storage_service"

module App
  class ProductService < CrudService(Product)
    def initialize(
      @repository : ProductRepository,
      @validator : ProductValidator,
      @storage_service : StorageService
    )
    end

    def create(entity : Product, file_upload : Kemal::FileUpload) : Product
      ext = file_upload.filename.not_nil!.split(".").last
      target_name = @storage_service.generate_random_name(ext)

      @storage_service.upload_file(file_upload.tempfile, target_name)

      entity.image = target_name

      if entity.order.nil?
        cursor = @repository.collection.aggregate([
          {"$group" => {"_id" => 1, "max_order" => {"$max" => "$order"}}},
        ])
        results = cursor.to_a
        next_order = 1
        if results.size > 0
          result = results[0]
          next_order = result["max_order"].as(Int32) + 1
        end

        entity.order = next_order
      end

      super(entity)
    end

    def update(entity : Product, file_upload : Kemal::FileUpload?) : Product
      unless file_upload.nil?
        ext = file_upload.filename.not_nil!.split(".").last
        target_name = @storage_service.generate_random_name(ext)

        @storage_service.upload_file(file_upload.tempfile, target_name)

        entity.image = target_name
      end

      super(entity)
    end

    def remove(id : String) : Void
      entity = @repository.find_by_id!(id)
      remove(entity)
    end

    def remove(entity : T) : Void
      unless entity.image.nil?
        if @storage_service.file_exists?(entity.image.not_nil!)
          @storage_service.file_delete(entity.image.not_nil!)
        end
      end

      @repository.remove(entity.id.not_nil!)
    end
  end
end
