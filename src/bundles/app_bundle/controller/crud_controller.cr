require "glassy-http"
require "../model/user"
require "../serializer/serializer"
require "../repository/user_repository"
require "../policy/crud_policy"
require "../repository/crud_repository"
require "../service/crud_service"

module App
  abstract class CrudController(T) < Glassy::HTTP::Controller
    # def initialize(
    #   @serializer : Serializer(T),
    #   @service : CrudService(T),
    #   @repository : CrudRepository(T),
    #   @policy : CrudPolicy(T),
    #   @user_repository : UserRepository
    # )
    # end

    def path_prefix : String
      raise "Must set a path prefix for crud controller"
    end

    @[Route("GET", "/", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def index(ctx : HTTP::Server::Context) : String
      entities = @repository.find_by({} of String => String)

      @serializer.serialize(entities)
    end

    @[Route("POST", "/", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def create(ctx : HTTP::Server::Context) : String
      json_any = ctx.params.json_any

      if json_any.nil?
        raise Glassy::HTTP::Exceptions::BadRequestException.new("Invalid json body")
      end

      user = get_user(ctx)

      entity = @serializer.deserialize!(json_any.not_nil!)

      unless @policy.can_create?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      @service.create(entity)

      ctx.response.status_code = 201

      @serializer.serialize(entity)
    end

    @[Route("GET", "/:id", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def show(ctx : HTTP::Server::Context) : String
      id = ctx.params.url["id"]
      user = get_user(ctx)

      entity = @repository.find_by_id(id)

      if entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_show?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      @serializer.serialize(entity)
    end

    @[Route("PATCH", "/:id", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def update(ctx : HTTP::Server::Context) : String
      id = ctx.params.url["id"]
      user = get_user(ctx)

      old_entity = @repository.find_by_id(id)

      if old_entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_update?(old_entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      json_any = ctx.params.json_any

      if json_any.nil?
        raise Glassy::HTTP::Exceptions::BadRequestException.new("Invalid json body")
      end

      entity = @serializer.deserialize!(json_any.not_nil!, old_entity)

      @service.update(entity)

      ctx.response.status_code = 200

      @serializer.serialize(entity)
    end

    @[Route("DELETE", "/:id", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def remove(ctx : HTTP::Server::Context) : String
      id = ctx.params.url["id"]
      user = get_user(ctx)

      entity = @repository.find_by_id(id)

      if entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_remove?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      @service.remove(entity.id.to_s)

      ctx.response.status_code = 204

      ""
    end

    def get_user(ctx : HTTP::Server::Context) : User
      user_id = ctx.get("user_id").to_s
      user = @user_repository.find_by_id(user_id)

      if user.nil?
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("User not found")
      end

      user.not_nil!
    end
  end
end
