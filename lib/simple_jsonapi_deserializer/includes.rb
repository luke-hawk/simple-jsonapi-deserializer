module SimpleJSONAPIDeserializer
  class Includes
    def initialize(includes = [])
      @includes = includes
      hash_includes
    end

    def find_by_id_and_type(id, type)
      return cache.cached_resource(id, type) if cache.cached?(id, type)

      includ = @hash_includes.dig(type, id)

      if includ
        resource = Resource.new(includ, self)
        cache.cache(id, type, resource.deserialize(without_relationships: true))
        deserialized_resource = resource.deserialize
        cache.cache(id, type, deserialized_resource)
        deserialized_resource
      else
        {}
      end
    end

    private

    attr_reader :includes

    def hash_includes
      @hash_includes ||= {}.tap do |hash_includes|
        includes.each do |includ|
          id = includ['id']
          type = includ['type']

          hash_includes[type] = {} unless hash_includes[type]
          hash_includes[type][id] = includ
        end
      end
    end

    def cache
      @cache ||= IncludesCache.new
    end
  end
end
