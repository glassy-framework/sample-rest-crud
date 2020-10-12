require "./crud_service"
require "../repository/product_category_repository"
require "../validator/product_category_validator"

module App
  class ProductCategoryService < CrudService(ProductCategory)
    def initialize(
      @repository : ProductCategoryRepository,
      @validator : ProductCategoryValidator
    )
    end

    def create(entity : ProductCategory) : ProductCategory
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

      super
    end
  end
end
