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
    #   @i18n : Glassy::I18n::Translator
    # )
    # end

    def path_prefix : String
      raise "Must set a path prefix for crud controller"
    end

    abstract def id_path : String

    @[Route("GET", "/", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def index(ctx : HTTP::Server::Context) : String
      user = get_user(ctx)
      entities = @repository.find_by(query_scope(ctx, user))

      @serializer.serialize(entities)
    end

    def query_scope(ctx : HTTP::Server::Context, user : App::User) : Hash
      {} of String => String
    end

    @[Route("POST", "/", middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def create(ctx : HTTP::Server::Context) : String
      json_body = get_json_body(ctx)

      if json_body.nil?
        raise Glassy::HTTP::Exceptions::BadRequestException.new("Invalid json body")
      end

      user = get_user(ctx)

      entity = @serializer.deserialize!(json_body.not_nil!)
      after_deserialize(ctx, entity)

      unless @policy.can_create?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      service_create(entity, ctx)

      ctx.response.status_code = 201

      @serializer.serialize(entity)
    end

    def service_create(entity : T, ctx : HTTP::Server::Context)
      @service.create(entity)
    end

    def after_deserialize(ctx : HTTP::Server::Context, entity : T) : Void
      # overwrite
    end

    def get_json_body(ctx)
      if ctx.params.body && ctx.params.body["json"]?
        json_any = JSON.parse(ctx.params.body["json"].not_nil!)
      else
        json_any = ctx.params.json_any
      end

      json_any
    end

    @[Route("GET", "/:" + id_path, middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def show(ctx : HTTP::Server::Context) : String
      id = ctx.params.url[id_path]
      user = get_user(ctx)

      entity = @repository.find_one_by(query_scope(ctx, user).merge({
        "_id" => BSON::ObjectId.new(id),
      }))

      if entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_show?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      @serializer.serialize(entity)
    end

    @[Route("PATCH", "/:" + id_path, middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def update(ctx : HTTP::Server::Context) : String
      id = ctx.params.url[id_path]
      user = get_user(ctx)

      old_entity = @repository.find_one_by(query_scope(ctx, user).merge({
        "_id" => BSON::ObjectId.new(id),
      }))

      if old_entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_update?(old_entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      json_body = get_json_body(ctx)

      if json_body.nil?
        raise Glassy::HTTP::Exceptions::BadRequestException.new("Invalid json body")
      end

      entity = @serializer.deserialize!(json_body.not_nil!, old_entity)
      after_deserialize(ctx, entity)

      service_update(entity, ctx)

      ctx.response.status_code = 200

      @serializer.serialize(entity)
    end

    def service_update(entity : T, ctx : HTTP::Server::Context)
      @service.update(entity)
    end

    @[Route("DELETE", "/:" + id_path, middlewares: ["auth"])]
    @[Context(arg: "ctx")]
    def remove(ctx : HTTP::Server::Context) : String
      id = ctx.params.url[id_path]
      user = get_user(ctx)

      entity = @repository.find_one_by(query_scope(ctx, user).merge({
        "_id" => BSON::ObjectId.new(id),
      }))

      if entity.nil?
        raise Glassy::HTTP::Exceptions::NotFoundException.new("Resource not found")
      end

      unless @policy.can_remove?(entity, user)
        raise Glassy::HTTP::Exceptions::UnauthorizedException.new("Permission denied")
      end

      service_remove(entity)

      ctx.response.status_code = 204

      ""
    end

    def service_remove(entity : T)
      @service.remove(entity.id.to_s)
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
