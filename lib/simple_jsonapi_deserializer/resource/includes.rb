module SimpleJSONAPIDeserializer
  class Resource::Includes
    def initialize(includes)
      @includes = includes
    end

    def find(id, type)
      indexed_includes.dig(type, id)
    end

    private

    attr_reader :includes

    def indexed_includes
      @indexed_includes ||= {}.tap do |indexed_includes|
        includes.each do |included_resource|
          id = included_resource['id']
          type = included_resource['type']

          indexed_includes[type] = {} unless indexed_includes[type]
          indexed_includes[type][id] = included_resource
        end
      end
    end
  end
end
