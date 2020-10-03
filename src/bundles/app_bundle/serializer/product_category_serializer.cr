require "./serializer"
require "../model/product_category"

module App
  class ProductCategorySerializer < Serializer(ProductCategory)
    # test 2
    identifier id
    type "product-categories"
    attribute name
    attribute order
  end
end
