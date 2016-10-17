module NetuitiveD
  class NetuitivedServer
    def initialize(metricAggregator, eventHandler)
      @metricAggregator = metricAggregator
      @eventHandler = eventHandler
    end

    def sendMetrics
      @metricAggregator.sendMetrics
    end

    def addSample(metricId, val)
      @metricAggregator.addSample(metricId, val)
    end

    def addCounterSample(metricId, val)
      @metricAggregator.addCounterSample(metricId, val)
    end

    def aggregateMetric(metricId, val)
      @metricAggregator.aggregateMetric(metricId, val)
    end

    def aggregateCounterMetric(metricId, val)
      @metricAggregator.aggregateCounterMetric(metricId, val)
    end

    def clearMetrics
      @metricAggregator.clearMetrics
    end

    def interval
      NetuitiveD::ConfigManager.interval
    end

    def event(message, timestamp = Time.new, title = 'Ruby Event', level = 'Info', source = 'Ruby Agent', type = 'INFO', tags = nil)
      @eventHandler.handleEvent(message, timestamp, title, level, source, type, tags)
    end

    def exceptionEvent(exception, klass = nil, tags = nil)
      @eventHandler.handleExceptionEvent(exception, klass, tags)
    end

    def stopServer
      Thread.new do
        exitProcess
      end
    end

    def exitProcess
      sleep(1)
      NetuitiveD::NetuitiveLogger.log.info 'stopping netuitived'
      Process.exit!(true)
    end

    private :exitProcess
  end
end
