require "../exception/validation_exception"

module App
  abstract class Validator(T)
    def validate(entity : T) : Bool
      begin
        validate!(entity)
        return true
      rescue ValidationException
        return false
      end
    end

    abstract def validate!(entity : T) : Void
  end
end
