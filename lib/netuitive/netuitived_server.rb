require 'netuitive/metric_aggregator'

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

	def aggregateMetric(metricId, val)
		@metricAggregator.aggregateMetric(metricId, val)
	end

	def clearMetrics
		@metricAggregator.clearMetrics
	end

end
 
