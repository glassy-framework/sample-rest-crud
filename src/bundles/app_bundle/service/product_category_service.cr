require "./crud_service"
require "../repository/product_category_repository"
require "../validator/product_category_validator"

module App
  class ProductCategoryService < CrudService(ProductCategory)
  end
end
