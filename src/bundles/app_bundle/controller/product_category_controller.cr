require "../model/product_category"
require "../policy/product_category_policy"
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
      @policy : ProductCategoryPolicy,
      @user_repository : UserRepository
    )
    end

    def path_prefix : String
      return "/product-categories"
    end
  end
end
