require "glassy-mongo-odm"
require "../model/product"
require "./crud_repository"

module App
  class ProductRepository < CrudRepository(Product)
  end
end
