require 'netuitive/api_emissary'
require 'netuitive/ingest_metric'
require 'netuitive/ingest_sample'
require 'netuitive/ingest_element'
require 'netuitive/netuitived_config_manager'
require 'netuitive/netuitived_logger'

class MetricAggregator
  def initialize
    @metrics = []
    @samples = []
    @aggregatedSamples = {}
    @metricMutex = Mutex.new
    @apiEmissary = APIEmissary.new
  end

  def sendMetrics
    elementString = nil
    addSample('netuitive.collection_interval', ConfigManager.interval)
    @metricMutex.synchronize do
      NetuitiveLogger.log.debug "self: #{object_id}"
      NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
      NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
      NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
      NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
      NetuitiveLogger.log.debug "metrics before send: #{@metrics.count}"
      NetuitiveLogger.log.debug "samples before send: #{@aggregatedSamples.count + @samples.count}"

      if @metrics.empty?
        NetuitiveLogger.log.info 'no netuitive metrics to report'
        return
      end
      aggregatedSamplesArray = @aggregatedSamples.values
      aggregatedSamplesArray.each do |sample|
        sample.timestamp = Time.new
      end
      element = IngestElement.new(ConfigManager.elementName, ConfigManager.elementName, 'Ruby', nil, @metrics, @samples + aggregatedSamplesArray, nil, nil)
      elements = [element]
      elementString = elements.to_json
      clearMetrics
    end
    @apiEmissary.sendElements(elementString)
  end

  def addSample(metricId, val)
    addSampleWithType(metricId, val, 'GAUGE')
  end

  def addCounterSample(metricId, val)
    addSampleWithType(metricId, val, 'COUNTER')
  end

  def addSampleWithType(metricId, val, type)
    @metricMutex.synchronize do
      NetuitiveLogger.log.debug 'start addSample method'
      NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
      NetuitiveLogger.log.debug "self: #{object_id}"
      NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
      NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
      NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
      NetuitiveLogger.log.debug "metrics before add: #{@metrics.count}"
      NetuitiveLogger.log.debug "samples before add: #{@aggregatedSamples.count + @samples.count}"
      if metricId.nil?
        NetuitiveLogger.log.info 'null metricId for addSample'
        return false
      end
      if val.nil?
        NetuitiveLogger.log.info "null value for addSample for metricId #{metricId}"
        return false
      end
      unless metricExists metricId
        NetuitiveLogger.log.info "adding new metric: #{metricId}"
        @metrics.push(IngestMetric.new(metricId, metricId, nil, type, nil, false))
      end
      @samples.push(IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil))
      NetuitiveLogger.log.info "netuitive sample added #{metricId} val: #{val}"
      NetuitiveLogger.log.debug "metrics after add: #{@metrics.count}"
      NetuitiveLogger.log.debug "samples after add: #{@aggregatedSamples.count + @samples.count}"
      NetuitiveLogger.log.debug 'end addSample method'
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
    @metricMutex.synchronize do
      NetuitiveLogger.log.debug 'start addSample method'
      NetuitiveLogger.log.debug "Thread: #{Thread.current.object_id}"
      NetuitiveLogger.log.debug "self: #{object_id}"
      NetuitiveLogger.log.debug "metrics id: #{@metrics.object_id}"
      NetuitiveLogger.log.debug "samples id: #{@samples.object_id}"
      NetuitiveLogger.log.debug "aggregatedSamples id: #{@aggregatedSamples.object_id}"
      NetuitiveLogger.log.debug "metrics before aggregate: #{@metrics.count}"
      NetuitiveLogger.log.debug "samples before aggregate: #{@aggregatedSamples.count + @samples.count}"
      if metricId.nil?
        NetuitiveLogger.log.info 'null metricId for aggregateMetric'
        return false
      end
      if val.nil?
        NetuitiveLogger.log.info "null value for aggregateMetric for metricId #{metricId}"
        return false
      end
      if !metricExists metricId
        NetuitiveLogger.log.info "adding new metric: #{metricId}"
        @metrics.push(IngestMetric.new(metricId, metricId, nil, type, nil, false))
        @aggregatedSamples[metricId.to_s] = IngestSample.new(metricId, Time.new, val, nil, nil, nil, nil, nil)
      else
        if @aggregatedSamples[metricId.to_s].nil?
          NetuitiveLogger.log.info "cannot aggregate metric #{metricId} that already has samples for this interval"
          return false
        end
        previousVal = @aggregatedSamples[metricId.to_s].val
        @aggregatedSamples[metricId.to_s].val += val
        NetuitiveLogger.log.info "netuitive sample aggregated #{metricId} old val: #{previousVal} new val: #{@aggregatedSamples[metricId.to_s].val}"
      end
      NetuitiveLogger.log.debug "metrics after aggregate: #{@metrics.count}"
      NetuitiveLogger.log.debug "samples after aggregate: #{@aggregatedSamples.count + @samples.count}"
      NetuitiveLogger.log.debug 'end addSample method'
    end
  end

  def clearMetrics
    NetuitiveLogger.log.debug 'start clearMetrics method'
    @metrics = []
    @samples = []
    @aggregatedSamples = {}
    NetuitiveLogger.log.info 'netuitive metrics cleared'
    NetuitiveLogger.log.debug 'end clearMetrics method'
  end
end
