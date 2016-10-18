module NetuitiveD
  class EventHandler
    def initialize(apiEmissary)
      @apiEmissary = apiEmissary
    end

    def handleEvent(message, timestamp, title, level, source, type, tags)
      NetuitiveD::NetuitiveLogger.log.debug "self: #{object_id}"
      NetuitiveD::NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
      NetuitiveD::NetuitiveLogger.log.debug "Received event: message:#{message}, timestamp:#{timestamp}, title:#{title}, level:#{level}, source:#{source}, type:#{type}, tags:#{tags}"
      event = NetuitiveD::IngestEvent.new(NetuitiveD::ConfigManager.elementName, message, timestamp, title, level, source, type, tags)
      events = [event]
      eventString = events.to_json
      @apiEmissary.sendEvents(eventString)
    rescue => e
      NetuitiveD::NetuitiveLogger.log.error "error in handling event: #{e.message}, backtrace: #{e.backtrace}"
    end

    def handleExceptionEvent(exception, klass, tags = {})
      message = "Exception Message: #{exception[:message]}\n" if (defined? exception[:message]) && !exception[:message].nil?
      message ||= ''
      timestamp = Time.new
      title = 'Ruby Exception'
      level = 'Warning'
      source = 'Ruby Agent'
      type = 'INFO'
      ingest_tags = []
      tags [:Exception] = klass unless klass.nil?
      tags.each do |key, value|
        next if !(defined? value) || value.nil? || value == ''
        ingest_tags << NetuitiveD::IngestTag.new(key, value)
        message += "#{key}: #{value}\n"
      end
      message += "Backtrace:\n\t#{exception[:backtrace]}" if (defined? exception[:backtrace]) && !exception[:backtrace].nil?
      handleEvent(message, timestamp, title, level, source, type, ingest_tags)
    rescue => e
      NetuitiveD::NetuitiveLogger.log.error "error in exception event: #{e.message}, backtrace: #{e.backtrace}"
    end
  end
end
