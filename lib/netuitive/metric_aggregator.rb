require 'netuitive/api_emissary'
require 'netuitive/ingest_metric'
require 'netuitive/ingest_sample'
require 'netuitive/ingest_element'
require 'netuitive/netuitived_config_manager'

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
			if ConfigManager.isDebug?
				puts "self: #{self.object_id}" 
				puts "Thread: #{Thread.current.object_id}"
				puts "metrics id: #{@metrics.object_id}"
				puts "samples id: #{@samples.object_id}"
				puts "aggregatedSamples id: #{@aggregatedSamples.object_id}"
				puts "metrics before send: #{@metrics.count}"
				puts "samples before send: #{@aggregatedSamples.count + @samples.count}"
			end

			if @metrics.empty?
				if ConfigManager.isInfo?
					puts "no netuitive metrics to report"
				end
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
			if ConfigManager.isDebug?
				puts "start addSample method"
				puts "Thread: #{Thread.current.object_id}"
				puts "self: #{self.object_id}" 
				puts "metrics id: #{@metrics.object_id}"
				puts "samples id: #{@samples.object_id}"
				puts "aggregatedSamples id: #{@aggregatedSamples.object_id}"
				puts "metrics before add: #{@metrics.count}"
				puts "samples before add: #{@aggregatedSamples.count + @samples.count}"
			end
			if not metricExists metricId
				if ConfigManager.isInfo?
					puts "adding new metric: #{metricId}"
				end
				@metrics.push(IngestMetric.new(metricId, metricId, nil, "custom", nil, false))
			end
			@samples.push(IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil))
			if ConfigManager.isInfo?
				puts "netuitive sample added #{metricId} val: #{val}"
			end
			if ConfigManager.isDebug?
				puts "metrics after add: #{@metrics.count}"
				puts "samples after add: #{@aggregatedSamples.count + @samples.count}"
				puts "end addSample method"
			end
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
			if ConfigManager.isDebug?
				puts "start addSample method"
				puts "Thread: #{Thread.current.object_id}"
				puts "self: #{self.object_id}" 
				puts "metrics id: #{@metrics.object_id}"
				puts "samples id: #{@samples.object_id}"
				puts "aggregatedSamples id: #{@aggregatedSamples.object_id}"
				puts "metrics before aggregate: #{@metrics.count}"
				puts "samples before aggregate: #{@aggregatedSamples.count + @samples.count}"
			end
			if not metricExists metricId
				if ConfigManager.isInfo?
					puts "adding new metric: #{metricId}"
				end
				@metrics.push(IngestMetric.new(metricId, metricId, nil, "custom", nil, false))
				@aggregatedSamples["#{metricId}"]=IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil)
			else
				previousVal = @aggregatedSamples["#{metricId}"].val
				@aggregatedSamples["#{metricId}"].val+=val
				if ConfigManager.isInfo?
					puts "netuitive sample aggregated #{metricId} old val: #{previousVal} new val: #{@aggregatedSamples["#{metricId}"].val}"
				end
			end
			if ConfigManager.isDebug?
				puts "metrics after aggregate: #{@metrics.count}"
				puts "samples after aggregate: #{@aggregatedSamples.count + @samples.count}"
				puts "end addSample method"
			end
		}
	end

	def clearMetrics
		if ConfigManager.isDebug?
			puts "start clearMetrics method"
		end
		@metrics=Array.new
		@samples=Array.new
		@aggregatedSamples=Hash.new
		if ConfigManager.isInfo?
			puts "netuitive metrics cleared"
		end
		if ConfigManager.isDebug?
			puts "end clearMetrics method"
		end
	end
end