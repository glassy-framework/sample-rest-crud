require "./serializer"
require "../model/product_category"

module App
  class ProductCategorySerializer < Serializer(ProductCategory)
    identifier id
    type "product-categories"
    attribute name
    attribute order
  end
end
