require 'json'
class IngestEvent
  attr_accessor :source, :timestamp, :title, :type, :tags, :data
  def initialize(elementId, message, timestamp, title, level, source, type, tags)
    @source = source
    @timestamp = timestamp
    @title = title
    @type = type
    @tags = tags
    @data = {"elementId" => elementId, "level" => level, "message" => message}
  end
  def to_json(options = {})
    millis = @timestamp.to_f * 1000
    {'source' => @source,
     'timestamp' => millis.round,
     'title' => @title,
     'type' => @type,
     'tags' => @tags,
     'data' => @data}.to_json.tr('\\"', '"')
  end
end
