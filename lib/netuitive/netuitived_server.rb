require 'netuitive/metric_aggregator'
require 'netuitive/event_handler'
require 'netuitive/netuitived_logger'
require 'netuitive/netuitived_config_manager'
class NetuitivedServer
  def initialize
    @metricAggregator = MetricAggregator.new
    @eventHandler = EventHandler.new
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
    ConfigManager.interval
  end

  def event(message, timestamp = Time.new, title = 'Ruby Event', level = 'Info', source = 'Ruby Agent', type = 'INFO', tags = nil)
    @eventHandler.handleEvent(message, timestamp, title, level, source, type, tags)
  end

  def exceptionEvent(exception, klass = nill, uri = nil, controller = nil, action = nil)
    @eventHandler.handleExceptionEvent(exception, klass, uri, controller, action)
  end

  def stopServer
    Thread.new do
      exitProcess
    end
  end

  def exitProcess
    sleep(1)
    NetuitiveLogger.log.info 'stopping netuitived'
    Process.exit!(true)
  end

  private :exitProcess
end
