require "spec-kemal"
require "spec"
require "dotenv"
require "../src/app_kernel"
require "./mocks/storage_service_mock"

Dotenv.load "#{__DIR__}/../.env.test"

Kemal.config.env = "test"
Kemal.config.port = 3030

class SpecContainer
  @@kernel = AppKernel.new

  @@kernel.container.app_storage_service = StorageServiceMock.new(@@kernel.container.app_s3_client, "", "http://localhost/%{bucket}/%{path}")

  http_kernel = @@kernel.container.http_kernel
  http_kernel.register_controllers(kernel.container.http_controller_builder_list)
  http_kernel.register_middlewares(kernel.container.http_middleware_list)
  http_kernel.run

  Spec.before_each do
    conn = @@kernel.container.db_connection
    conn.client[kernel.container.config.get("db.default_database").not_nil!].drop
  end

  def self.kernel
    @@kernel
  end
end

def post_json(path : String, body : String, headers : HTTP::Headers? = nil)
  headers ||= HTTP::Headers.new
  headers["Content-Type"] = "application/json"

  post path, headers, body
end

def patch_json(path : String, body : String, headers : HTTP::Headers? = nil)
  headers ||= HTTP::Headers.new
  headers["Content-Type"] = "application/json"

  patch path, headers, body
end

def create_user : App::User
  user = App::User.new("My Name", "test@email.com")
  SpecContainer.kernel.container.app_user_repository.save(user)
  user
end

def create_access_token(user : App::User) : String
  result = SpecContainer.kernel.container.app_auth_service.login_user(user)
  result[:access_token]
end

def create_product_category : App::ProductCategory
  create_product_category do |entity|
    # do nothing
  end
end

def create_product_category(&block : Proc(App::ProductCategory, Void)) : App::ProductCategory
  model = App::ProductCategory.new("Test Name")

  if block
    block.call(model)
  end

  SpecContainer.kernel.container.app_product_category_repository.save(model)

  model
end

def create_product : App::Product
  create_product do |entity|
    # do nothing
  end
end

def create_product(&block : Proc(App::Product, Void)) : App::Product
  model = App::Product.new("Test Product")

  if block
    block.call(model)
  end

  SpecContainer.kernel.container.app_product_repository.save(model)

  model
end
