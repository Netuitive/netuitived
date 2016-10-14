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
    NetuitiveLogger.log.debug "self: #{object_id}"
    NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
    NetuitiveLogger.log.debug "Received event: message:#{message}, timestamp:#{timestamp}, title:#{title}, level:#{level}, source:#{source}, type:#{type}, tags:#{tags}"
    event = IngestEvent.new(ConfigManager.elementName, message, timestamp, title, level, source, type, tags)
    events = [event]
    eventString = events.to_json
    @apiEmissary.sendEvents(eventString)
  end

  def handleExceptionEvent(exception, klass, tags = {})
    message = "Exception Message: #{exception.message}\n"
    timestamp = Time.new
    title = 'Ruby Exception'
    level = 'Warning'
    source = 'Ruby Agent'
    type = 'INFO'
    ingest_tags = []
    tags [:Exception] = klass unless klass.nil?
    tags.each do |key, value|
      next if value.nil? || value == ''
      ingest_tags << IngestTag.new(key, value)
      message += "#{key}: #{value}\n"
    end
    message += "Backtrace:\n\t#{exception.backtrace.join("\n\t")}"
    handleEvent(message, timestamp, title, level, source, type, ingest_tags)
  end
end
