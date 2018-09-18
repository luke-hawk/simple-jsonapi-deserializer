module SimpleJSONAPIDeserializer
  class Resource
    def self.deserialize(resource = {})
      data = resource.fetch('data', {})
      includes = resource.fetch('include', [])

      new(
        data,
        Includes.new(includes)
      ).deserialize
    rescue NoMethodError
      raise ParseError
    end

    def initialize(resource, includes)
      @resource = resource
      @includes = includes
    end

    def deserialize(without_relationships: false)
      {}.tap do |deserialized_resource|
        deserialized_resource.merge!(attributes)
        deserialized_resource.merge!(deserialize_relationships) unless without_relationships
        deserialized_resource['type'] = type if type
        deserialized_resource['id'] = id if id
      end
    end

    def attributes
      resource.fetch('attributes', {})
    end

    private

    attr_reader :includes, :resource

    def deserialize_relationships
      {}.tap do |deserialized_relationships|
        relationships.each do |key, value|
          data = value['data']

          if data.is_a?(Array)
            deserialized_relationships[key] = data.map do |relationship|
              deserialize_relationship(relationship)
            end
          else
            deserialized_relationships[key] = deserialize_relationship(data)
          end
        end
      end
    end

    def deserialize_relationship(relationship = {})
      includ = includes.find_by_id_and_type(relationship['id'], relationship['type'])
      includ.empty? ? Resource.new(relationship, includes).deserialize : includ
    end

    def id
      resource['id']
    end

    def type
      resource['type']
    end

    def relationships
      resource.fetch('relationships', {})
    end
  end
end
