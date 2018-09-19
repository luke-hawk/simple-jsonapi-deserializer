require 'simple_jsonapi_deserializer/deserializer'
require 'simple_jsonapi_deserializer/parse_error'
require 'simple_jsonapi_deserializer/resource'
require 'simple_jsonapi_deserializer/resource/cache'
require 'simple_jsonapi_deserializer/resource/includes'
require 'simple_jsonapi_deserializer/version'

module SimpleJSONAPIDeserializer
  class << self
    def deserialize(resource)
      Deserializer.new(resource).deserialize
    end
  end
end
