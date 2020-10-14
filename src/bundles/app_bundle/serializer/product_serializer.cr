require "./serializer"
require "../model/product"
require "./public_url_serializer"

module App
  class ProductSerializer < Serializer(Product)
    def initialize(@public_url_serializer : PublicUrlSerializer, options : JSONApiSerializer::SerializeOptions? = nil)
      super(options)
    end

    identifier id
    type "products"
    attribute name
    attribute order
    attribute(image) { @public_url_serializer }
    relationship_id category_id, "category", "categories"
  end
end
