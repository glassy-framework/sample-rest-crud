require "./crud_policy"
require "../model/user"
require "../model/product_category"

module App
  class DefaultPolicy(T) < CrudPolicy(T)
    def can_create?(entity : T, user : User)
      return true
    end

    def can_update?(entity : T, user : User)
      return true
    end

    def can_remove?(entity : T, user : User)
      return true
    end

    def can_show?(entity : T, user : User)
      return true
    end
  end
end
