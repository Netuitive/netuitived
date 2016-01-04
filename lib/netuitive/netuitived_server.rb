require 'netuitive/metric_aggregator'
require 'netuitive/netuitived_logger'
require 'netuitive/netuitived_config_manager'
class NetuitivedServer

	def initialize()
		@metricAggregator = MetricAggregator.new
	end

	def sendMetrics()
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

	def clearMetrics
		@metricAggregator.clearMetrics
	end

	def interval()
		return ConfigManager.interval
	end

	def stopServer
		Thread.new do
    		exitProcess
    	end
	end

	def exitProcess
		sleep(1)
		NetuitiveLogger.log.info "stopping netuitived"
		Process.exit!(true)
	end

	private :exitProcess

end
 
