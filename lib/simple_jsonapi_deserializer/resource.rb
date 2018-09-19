module SimpleJSONAPIDeserializer
  class Resource
    def self.deserialize(resource)
      data = resource['data'] || {}
      includes = Includes.new(resource['include'] || [])
      cache = Cache.new

      if data.is_a?(Array)
        data.map { |res| new(res, includes, cache).deserialize(without_attributes: true) }
      else
        new(data, includes, cache).deserialize
      end
    rescue TypeError, NoMethodError => e
      raise ParseError, e
    end

    def initialize(resource, includes, cache)
      @resource = resource
      @includes = includes
      @cache = cache
    end

    def deserialize(without_attributes: false, without_relationships: false)
      {}.tap do |deserialized_resource|
        deserialized_resource.merge!(attributes) unless without_attributes
        deserialized_resource.merge!(deserialized_relationships) unless without_relationships
        deserialized_resource['type'] = type if type
        deserialized_resource['id'] = id if id
      end
    end

    def id
      resource['id']
    end

    def type
      resource['type']
    end

    private

    attr_reader :cache, :includes, :resource

    def attributes
      resource['attributes'] || {}
    end

    def relationships
      resource['relationships'] || {}
    end

    def deserialized_relationships
      {}.tap do |deserialized_relationships|
        relationships.each do |key, value|
          data = value['data']

          deserialized_relationships[key] = if data.is_a?(Array)
                                              deserialize_relationships(data)
                                            else
                                              deserialize_relationship(data)
                                            end
        end
      end
    end

    def deserialize_relationships(relationships)
      relationships.map do |relationship|
        deserialize_relationship(relationship)
      end
    end

    def deserialize_relationship(relationship)
      id = relationship['id']
      type = relationship['type']
      cached_resource = read_from_cache(id, type)
      included_resource = read_from_includes(id, type)

      return cached_resource if cached_resource

      deserialize_and_cache_relationship(included_resource || relationship)
    end

    def deserialize_and_cache_relationship(relationship)
      resource = Resource.new(relationship, includes, cache)

      write_to_cache(resource.id, resource.type, resource.deserialize(without_relationships: true))

      resource.deserialize.tap do |deserialized_resource|
        write_to_cache(resource.id, resource.type, deserialized_resource)
      end
    end

    def read_from_includes(id, type)
      includes.find(id, type)
    end

    def write_to_cache(id, type, deserialized_resource)
      cache.cache(id, type, deserialized_resource)
    end

    def read_from_cache(id, type)
      cache.find(id, type)
    end
  end
end
