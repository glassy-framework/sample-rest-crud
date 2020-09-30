require "glassy-kernel"
require "./serializer/*" # Fix serializer reading model
require "./command/*"
require "./controller/*"
require "./exception/error_handler"
require "./middleware/*"

module App
  class Bundle < Glassy::Kernel::Bundle
    SERVICES_PATH = "#{__DIR__}/config/services.yml"
  end
end
