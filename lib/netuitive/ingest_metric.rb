require 'json'
class IngestMetric
  attr_accessor :id, :name, :unit, :type, :tags, :aggregate
  def initialize(id, name, unit, type, tags, aggregate)
    @id=id
    @name=name
    @unit=unit
    @type=type
    @tags=tags
    @aggregate=aggregate
  end
  def to_json(options = {})
    {'id' => @id,'name' => @name, 'unit' => @unit,'type' => @type, 'tags' => @tags}.to_json
  end
end
