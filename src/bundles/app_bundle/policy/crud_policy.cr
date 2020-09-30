require "../model/user"

module App
  abstract class CrudPolicy(T)
    def can_create?(entity : T, user : User)
      return false
    end

    def can_update?(entity : T, user : User)
      return false
    end

    def can_remove?(entity : T, user : User)
      return false
    end

    def can_show?(entity : T, user : User)
      return false
    end
  end
end
