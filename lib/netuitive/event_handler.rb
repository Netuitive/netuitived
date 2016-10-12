require 'netuitive/api_emissary'
require 'netuitive/ingest_event'
require 'netuitive/ingest_tag'
require 'netuitive/netuitived_config_manager'
require 'netuitive/netuitived_logger'

class EventHandler
  def initialize
    @apiEmissary = APIEmissary.new
  end

  def handleEvent(message, timestamp, title, level, source, type, tags)
    eventString = nil
    NetuitiveLogger.log.debug "self: #{object_id}"
    NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
    NetuitiveLogger.log.debug "Received event: message:#{message}, timestamp:#{timestamp}, title:#{title}, level:#{level}, source:#{source}, type:#{type}, tags:#{tags}"
    event = IngestEvent.new(ConfigManager.elementName, message, timestamp, title, level, source, type, tags)
    events = [event]
    eventString = events.to_json
    @apiEmissary.sendEvents(eventString)
  end

  def handleExceptionEvent(exception, klass, uri, controller, action)
    message = "Exception Type: #{klass}\nException Message: #{exception.message}\nBacktrace:\n\t#{exception.backtrace.join("\n\t")}"
    timestamp = Time.new
    title = 'Ruby Exception'
    level = 'Warning'
    source = 'Ruby Agent'
    type = 'INFO'
    tags = []
    tags << IngestTag.new('URI', uri) unless uri.nil?
    tags << IngestTag.new('Exception', klass) unless klass.nil?
    tags << IngestTag.new('Controller', controller) unless controller.nil?
    tags << IngestTag.new('Action', action) unless action.nil?
    handleEvent(message, timestamp, title, level, source, type, tags)
  end
end
