require "glassy-i18n"
require "../model/product_category"
require "../exception/validation_exception"
require "./validator"

module App
  class ProductCategoryValidator < Validator(ProductCategory)
    def initialize(@i18n : Glassy::I18n::Translator)
    end

    def validate!(entity : ProductCategory) : Void
      if entity.name.nil? || entity.name == ""
        raise ValidationException.new(@i18n.t("validation.messages.required", {
          "attr" => @i18n.t("validation.attributes.name")
        }))
      end
    end
  end
end
