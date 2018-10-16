module NetuitiveD
  class MetricAggregator
    attr_reader :samples
    attr_reader :metrics
    attr_reader :aggregatedSamples

    def initialize(apiEmissary)
      @metrics = []
      @samples = []
      @tags = []
      @aggregatedSamples = {}
      @metricMutex = Mutex.new
      @apiEmissary = apiEmissary
    end

    def add_samples(samples)
      return unless samples && !samples.nil?
      samples.each { |sample| addSample(sample[:metric_id], sample[:val]) }
    end

    def add_counter_samples(samples)
      return unless samples && !samples.nil?
      samples.each { |sample| addCounterSample(sample[:metric_id], sample[:val]) }
    end

    def add_aggregate_metrics(samples)
      return unless samples && !samples.nil?
      samples.each { |sample| aggregateMetric(sample[:metric_id], sample[:val]) }
    end

    def add_aggregate_counter_metrics(samples)
      return unless samples && !samples.nil?
      samples.each { |sample| aggregateCounterMetric(sample[:metric_id], sample[:val]) }
    end

    def sendMetrics
      NetuitiveD::ErrorLogger.guard('exception during sendMetrics') do
        elementString = nil
        addSample('netuitive.collection_interval', NetuitiveD::ConfigManager.interval)
        @metricMutex.synchronize do
          NetuitiveD::NetuitiveLogger.log.debug "self: #{object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics before send: #{@metrics.count}"
          NetuitiveD::NetuitiveLogger.log.debug "samples before send: #{@aggregatedSamples.count + @samples.count}"

          if @metrics.empty?
            NetuitiveD::NetuitiveLogger.log.info 'no netuitive metrics to report'
            return
          end
          aggregatedSamplesArray = @aggregatedSamples.values
          aggregatedSamplesArray.each do |sample|
            sample.timestamp = Time.new
          end
	        unless NetuitiveD::ConfigManager.elementTags.nil?
            for tag in NetuitiveD::ConfigManager.elementTags.split(',').map(&:strip) do
              @tags.push(NetuitiveD::IngestTag.new(tag.split(':')[0], tag.split(':')[1]))
            end
	        end
          element = NetuitiveD::IngestElement.new(NetuitiveD::ConfigManager.elementName, NetuitiveD::ConfigManager.elementName, 'Ruby', nil, @metrics, @samples + aggregatedSamplesArray, @tags, nil)
          elements = [element]
          elementString = elements.to_json
          clearMetrics
        end
        @apiEmissary.sendElements(elementString)
      end
    end

    def addSample(metricId, val)
      addSampleWithType(metricId, val, 'GAUGE')
    end

    def addCounterSample(metricId, val)
      addSampleWithType(metricId, val, 'COUNTER')
    end

    def addSampleWithType(metricId, val, type)
      NetuitiveD::ErrorLogger.guard('exception during addSampleWithType') do
        @metricMutex.synchronize do
          NetuitiveD::NetuitiveLogger.log.debug 'start addSample method'
          NetuitiveD::NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "self: #{object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics before add: #{@metrics.count}"
          NetuitiveD::NetuitiveLogger.log.debug "samples before add: #{@aggregatedSamples.count + @samples.count}"
          if metricId.nil?
            NetuitiveD::NetuitiveLogger.log.info 'null metricId for addSample'
            return false
          end
          if val.nil?
            NetuitiveD::NetuitiveLogger.log.info "null value for addSample for metricId #{metricId}"
            return false
          end
          unless metricExists metricId
            NetuitiveD::NetuitiveLogger.log.info "adding new metric: #{metricId}"
            @metrics.push(NetuitiveD::IngestMetric.new(metricId, metricId, nil, type, nil, false))
          end
          @samples.push(NetuitiveD::IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil))
          NetuitiveD::NetuitiveLogger.log.info "netuitive sample added #{metricId} val: #{val}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics after add: #{@metrics.count}"
          NetuitiveD::NetuitiveLogger.log.debug "samples after add: #{@aggregatedSamples.count + @samples.count}"
          NetuitiveD::NetuitiveLogger.log.debug 'end addSample method'
        end
      end
    end

    def metricExists(metricId)
      @metrics.each do |metric|
        return true if metric.id == metricId
      end
      false
    end

    def aggregateMetric(metricId, val)
      aggregateMetricWithType(metricId, val, 'GAUGE')
    end

    def aggregateCounterMetric(metricId, val)
      aggregateMetricWithType(metricId, val, 'COUNTER')
    end

    def aggregateMetricWithType(metricId, val, type)
      NetuitiveD::ErrorLogger.guard('exception during aggregateMetricWithType') do
        @metricMutex.synchronize do
          NetuitiveD::NetuitiveLogger.log.debug 'start addSample method'
          NetuitiveD::NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "self: #{object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
          NetuitiveD::NetuitiveLogger.log.debug "metrics before aggregate: #{@metrics.count}"
          NetuitiveD::NetuitiveLogger.log.debug "samples before aggregate: #{@aggregatedSamples.count + @samples.count}"
          if metricId.nil?
            NetuitiveD::NetuitiveLogger.log.info 'null metricId for aggregateMetric'
            return false
          end
          if val.nil?
            NetuitiveD::NetuitiveLogger.log.info "null value for aggregateMetric for metricId #{metricId}"
            return false
          end
          if !metricExists metricId
            NetuitiveD::NetuitiveLogger.log.info "adding new metric: #{metricId}"
            @metrics.push(NetuitiveD::IngestMetric.new(metricId, metricId, nil, type, nil, false))
            @aggregatedSamples[metricId.to_s] = NetuitiveD::IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil)
          else
            if @aggregatedSamples[metricId.to_s].nil?
              NetuitiveD::NetuitiveLogger.log.info "cannot aggregate metric #{metricId} that already has samples for this interval"
              return false
            end
            previousVal = @aggregatedSamples[metricId.to_s].val
            @aggregatedSamples[metricId.to_s].val += val
            NetuitiveD::NetuitiveLogger.log.info "netuitive sample aggregated #{metricId} old val: #{previousVal} new val: #{@aggregatedSamples[metricId.to_s].val}"
          end
          NetuitiveD::NetuitiveLogger.log.debug "metrics after aggregate: #{@metrics.count}"
          NetuitiveD::NetuitiveLogger.log.debug "samples after aggregate: #{@aggregatedSamples.count + @samples.count}"
          NetuitiveD::NetuitiveLogger.log.debug 'end addSample method'
        end
      end
    end

    def clearMetrics
      NetuitiveD::ErrorLogger.guard('exception during clearMetrics') do
        NetuitiveD::NetuitiveLogger.log.debug 'start clearMetrics method'
        @metrics = []
        @samples = []
        @aggregatedSamples = {}
        NetuitiveD::NetuitiveLogger.log.info 'netuitive metrics cleared'
        NetuitiveD::NetuitiveLogger.log.debug 'end clearMetrics method'
      end
    end
  end
end
