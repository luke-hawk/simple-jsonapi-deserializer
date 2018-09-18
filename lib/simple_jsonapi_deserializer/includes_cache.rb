module SimpleJSONAPIDeserializer
  class IncludesCache
    def initialize()
      @cached_resources = {}
    end

    def cache(id, type, deserialized_resource)
      cached_resources[type] ||= {}
      cached_resources[type][id] = deserialized_resource
    end

    def cached?(id, type)
      cached_resource(id, type)
    end

    def cached_resource(id, type)
      cached_resources.dig(type, id)
    end

    private

    attr_reader :cached_resources
  end
end
