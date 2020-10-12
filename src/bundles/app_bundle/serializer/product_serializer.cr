require "./serializer"
require "../model/product"

module App
  class ProductSerializer < Serializer(Product)
    identifier id
    type "products"
    attribute name
    attribute order
    attribute image
    relationship_id category_id, "category", "categories"
  end
end
