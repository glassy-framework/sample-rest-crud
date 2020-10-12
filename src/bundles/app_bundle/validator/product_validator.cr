require "glassy-i18n"
require "../model/product"
require "../exception/validation_exception"
require "./validator"

module App
  class ProductValidator < Validator(Product)
    def initialize(@i18n : Glassy::I18n::Translator)
    end

    def validate!(entity : Product) : Void
      if entity.name.empty?
        raise ValidationException.new(@i18n.t("validation.messages.required", {
          "attr" => @i18n.t("validation.attributes.name"),
        }))
      end

      if entity.image.nil? || entity.image.not_nil!.empty?
        raise ValidationException.new(@i18n.t("validation.messages.the_image_is_required"))
      end
    end
  end
end
