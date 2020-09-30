require "./crud_policy"
require "../model/user"
require "../model/product_category"

module App
  class ProductCategoryPolicy < CrudPolicy(ProductCategory)
    def can_create?(entity : ProductCategory, user : User)
      return true
    end

    def can_update?(entity : ProductCategory, user : User)
      return true
    end

    def can_remove?(entity : ProductCategory, user : User)
      return true
    end

    def can_show?(entity : ProductCategory, user : User)
      return true
    end
  end
end
