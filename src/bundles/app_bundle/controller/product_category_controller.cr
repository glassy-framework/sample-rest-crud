require "glassy-i18n"
require "../model/product_category"
require "../policy/default_policy"
require "../serializer/product_category_serializer"
require "../repository/product_category_repository"
require "../service/product_category_service"
require "../repository/user_repository"
require "./crud_controller"

module App
  class ProductCategoryController < CrudController(ProductCategory)
    def initialize(
      @serializer : ProductCategorySerializer,
      @service : ProductCategoryService,
      @repository : ProductCategoryRepository,
      @policy : DefaultPolicy(ProductCategory),
      @user_repository : UserRepository,
      @i18n : Glassy::I18n::Translator
    )
    end

    def path_prefix : String
      return "/product-categories"
    end

    def id_path : String
      "category"
    end
  end
end
