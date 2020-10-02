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
  end
end
