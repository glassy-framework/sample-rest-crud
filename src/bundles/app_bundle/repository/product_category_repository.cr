require "glassy-mongo-odm"
require "../model/product_category"
require "./crud_repository"

module App
  class ProductCategoryRepository < CrudRepository(ProductCategory)
  end
end
