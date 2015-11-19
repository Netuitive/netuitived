require 'netuitive/api_emissary'
require 'netuitive/ingest_metric'
require 'netuitive/ingest_sample'
require 'netuitive/ingest_element'
require 'netuitive/netuitived_config_manager'
require 'netuitive/netuitived_logger'

class MetricAggregator

	def initialize()
		@metrics=Array.new
		@samples=Array.new
		@aggregatedSamples=Hash.new
		@metricMutex=Mutex.new
		@apiEmissary=APIEmissary.new
	end

	def sendMetrics()
		elementString=nil
		@metricMutex.synchronize{
			NetuitiveLogger.log.debug "self: #{self.object_id}" 
			NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
			NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
			NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
			NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
			NetuitiveLogger.log.debug "metrics before send: #{@metrics.count}"
			NetuitiveLogger.log.debug "samples before send: #{@aggregatedSamples.count + @samples.count}"

			if @metrics.empty?
				NetuitiveLogger.log.info "no netuitive metrics to report"
				return
			end
			aggregatedSamplesArray = @aggregatedSamples.values
			aggregatedSamplesArray.each do |sample|
				sample.timestamp=Time.new
			end
			element=IngestElement.new(ConfigManager.elementName, ConfigManager.elementName, "custom", nil, @metrics, @samples+aggregatedSamplesArray, nil, nil)
			elements= [element]
			elementString=elements.to_json
			clearMetrics
		}
		@apiEmissary.sendElements(elementString)
	end

	def addSample(metricId, val)
		@metricMutex.synchronize{
			NetuitiveLogger.log.debug "start addSample method"
			NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
			NetuitiveLogger.log.debug "self: #{self.object_id}" 
			NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
			NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
			NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
			NetuitiveLogger.log.debug "metrics before add: #{@metrics.count}"
			NetuitiveLogger.log.debug "samples before add: #{@aggregatedSamples.count + @samples.count}"
			if not metricExists metricId
				NetuitiveLogger.log.info "adding new metric: #{metricId}"
				@metrics.push(IngestMetric.new(metricId, metricId, nil, "custom", nil, false))
			end
			@samples.push(IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil))
			NetuitiveLogger.log.info "netuitive sample added #{metricId} val: #{val}"
			NetuitiveLogger.log.debug "metrics after add: #{@metrics.count}"
			NetuitiveLogger.log.debug "samples after add: #{@aggregatedSamples.count + @samples.count}"
			NetuitiveLogger.log.debug "end addSample method"
		}
	end

	def metricExists(metricId)
		@metrics.each do |metric|
			if metric.id == metricId
				return true
			end
		end
		return false
	end

	def aggregateMetric(metricId, val)
		@metricMutex.synchronize{
			NetuitiveLogger.log.debug "start addSample method"
			NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
			NetuitiveLogger.log.debug "self: #{self.object_id}" 
			NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
			NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
			NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
			NetuitiveLogger.log.debug "metrics before aggregate: #{@metrics.count}"
			NetuitiveLogger.log.debug "samples before aggregate: #{@aggregatedSamples.count + @samples.count}"
			if not metricExists metricId
				NetuitiveLogger.log.info "adding new metric: #{metricId}"
				@metrics.push(IngestMetric.new(metricId, metricId, nil, "custom", nil, false))
				@aggregatedSamples["#{metricId}"]=IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil)
			else
				previousVal = @aggregatedSamples["#{metricId}"].val
				@aggregatedSamples["#{metricId}"].val+=val
				NetuitiveLogger.log.info "netuitive sample aggregated #{metricId} old val: #{previousVal} new val: #{@aggregatedSamples["#{metricId}"].val}"
			end
			NetuitiveLogger.log.debug "metrics after aggregate: #{@metrics.count}"
			NetuitiveLogger.log.debug "samples after aggregate: #{@aggregatedSamples.count + @samples.count}"
			NetuitiveLogger.log.debug "end addSample method"
		}
	end

	def clearMetrics
		NetuitiveLogger.log.debug "start clearMetrics method"
		@metrics=Array.new
		@samples=Array.new
		@aggregatedSamples=Hash.new
		NetuitiveLogger.log.info "netuitive metrics cleared"
		NetuitiveLogger.log.debug "end clearMetrics method"
	end
end