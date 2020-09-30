require "../model/product_category"
require "../exception/validation_exception"
require "./validator"

module App
  class ProductCategoryValidator < Validator(ProductCategory)
    def validate!(entity : ProductCategory) : Void
      if entity.name.nil? || entity.name == ""
        raise ValidationException.new("Name is required")
      end
    end
  end
end
