module SimpleJSONAPIDeserializer
  class Deserializer
    def initialize(resource)
      @resource = resource
    end

    def deserialize
      return Resource.new(data, includes, cache).deserialize unless data.is_a?(Array)

      data.map do |resource|
        Resource
          .new(resource, includes, cache)
          .deserialize(without_attributes: true)
      end
    rescue TypeError, NoMethodError => e
      raise ParseError, e
    end

    private

    attr_reader :resource

    def cache
      Resource::Cache.new
    end

    def data
      resource['data'] || {}
    end

    def includes
      Resource::Includes.new(resource['included'] || [])
    end
  end
end
