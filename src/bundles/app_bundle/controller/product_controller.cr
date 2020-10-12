require "glassy-i18n"
require "../model/product"
require "../policy/default_policy"
require "../serializer/product_serializer"
require "../repository/product_repository"
require "../service/product_service"
require "../repository/user_repository"
require "./crud_controller"
require "../exception/validation_exception"

module App
  class ProductController < CrudController(Product)
    def initialize(
      @serializer : ProductSerializer,
      @service : ProductService,
      @repository : ProductRepository,
      @policy : DefaultPolicy(Product),
      @user_repository : UserRepository,
      @i18n : Glassy::I18n::Translator
    )
    end

    def path_prefix : String
      "/product-categories/:category/products"
    end

    def id_path : String
      "product"
    end

    def query_scope(ctx : HTTP::Server::Context, user : App::User) : Hash
      {
        "category_id" => BSON::ObjectId.new(ctx.params.url["category"]),
      }
    end

    def after_deserialize(ctx : HTTP::Server::Context, entity : Product) : Void
      entity.category_id = BSON::ObjectId.new(ctx.params.url["category"])
    end

    def service_create(entity : Product, ctx : HTTP::Server::Context)
      unless ctx.request.headers["Content-Type"].starts_with?("multipart/form-data")
        raise ValidationException.new(@i18n.t("validation.messages.the_image_is_required"))
      end

      file_upload = ctx.params.files["image"]?

      if file_upload.nil?
        raise ValidationException.new(@i18n.t("validation.messages.the_image_is_required"))
      end

      @service.create(entity, file_upload.not_nil!)
    end

    def service_update(entity : Product, ctx : HTTP::Server::Context)
      if ctx.request.headers["Content-Type"].starts_with?("multipart/form-data")
        file_upload = ctx.params.files["image"]?
      else
        file_upload = nil
      end

      @service.update(entity, file_upload)
    end

    def service_remove(entity : T)
      @service.remove(entity.id.to_s)
    end

    def service_remove(entity : T)
      @service.remove(entity)
    end
  end
end
