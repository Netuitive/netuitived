require 'json'
class IngestElement
    attr_accessor :id, :name, :type, :location, :metrics, :samples, :tags, :attributes
    def initialize(id, name, type, location, metrics, samples, tags, attributes)
        @id=id
        @name=name
        @type=type
        @location=location
        @metrics=metrics
        @samples=samples
        @tags=tags
        @attributes=attributes
    end
    def to_json(options = {})
        {'id' => @id, 'name' => @name, 'type' => @type, 'location' => @location, 'metrics' => @metrics, 'samples' => @samples,'tags' => @tags, 'attributes' => @attributes}.to_json.tr('\\"', '"')
    end
end
