require 'test/unit'
require 'mocha/test_unit'
require 'netuitive/metric_aggregator'
require 'netuitive/netuitived_logger'
require 'netuitive/api_emissary'

class MetricAggregatorTest < Test::Unit::TestCase
  def setup
    @api_emissary = mock
    @metric_aggregator = MetricAggregator.new(@api_emissary)
    NetuitiveLogger.setup
  end

  def test_add_sample
    @metric_aggregator.addSample('test.metric', 5)
    assert_equal(@metric_aggregator.metrics.length, 1)
    metric = @metric_aggregator.metrics[0]
    assert_equal(metric.id, 'test.metric')
    assert_equal(metric.type, 'GAUGE')
    assert_equal(@metric_aggregator.samples.length, 1)
    sample = @metric_aggregator.samples[0]
    assert_equal(sample.metricId, 'test.metric')
    assert_equal(sample.val, 5)
  end

  def test_add_counter_sample
    @metric_aggregator.addCounterSample('test.metric', 5)
    assert_equal(@metric_aggregator.metrics.length, 1)
    metric = @metric_aggregator.metrics[0]
    assert_equal(metric.id, 'test.metric')
    assert_equal(metric.type, 'COUNTER')
    assert_equal(@metric_aggregator.samples.length, 1)
    sample = @metric_aggregator.samples[0]
    assert_equal(sample.metricId, 'test.metric')
    assert_equal(sample.val, 5)
  end

  def test_aggregate_metric
    @metric_aggregator.aggregateMetric('test.metric', 1)
    @metric_aggregator.aggregateMetric('test.metric', 1)
    assert_equal(@metric_aggregator.metrics.length, 1)
    metric = @metric_aggregator.metrics[0]
    assert_equal(metric.id, 'test.metric')
    assert_equal(metric.type, 'GAUGE')
    assert_equal(@metric_aggregator.aggregatedSamples.length, 1)
    sample = @metric_aggregator.aggregatedSamples['test.metric']
    assert_equal(sample.metricId, 'test.metric')
    assert_equal(sample.val, 2)
  end

  def test_aggregate_counter_metric
    @metric_aggregator.aggregateCounterMetric('test.metric', 1)
    @metric_aggregator.aggregateCounterMetric('test.metric', 1)
    assert_equal(@metric_aggregator.metrics.length, 1)
    metric = @metric_aggregator.metrics[0]
    assert_equal(metric.id, 'test.metric')
    assert_equal(metric.type, 'COUNTER')
    assert_equal(@metric_aggregator.aggregatedSamples.length, 1)
    sample = @metric_aggregator.aggregatedSamples['test.metric']
    assert_equal(sample.metricId, 'test.metric')
    assert_equal(sample.val, 2)
  end

  def test_metric_exists
    @metric_aggregator.addSample('test.metric', 5)
    assert(@metric_aggregator.metricExists('test.metric'))
    assert(!@metric_aggregator.metricExists('wrong.id'))
  end

  def test_send_metrics
    @metric_aggregator.addSample('test.metric', 5)
    @metric_aggregator.aggregateMetric('test.aggregate.metric', 1)
    @api_emissary.expects(:sendElements).once.with(regexp_matches(Regexp.new(
                                                                    Regexp.quote('[{"id":null,"name":null,"type":"Ruby","location":null,"metrics":[{"id":"test.metric","name":"test.metric","unit":null,"type":"GAUGE","tags":null},{"id":"test.aggregate.metric","name":"test.aggregate.metric","unit":null,"type":"GAUGE","tags":null}],"samples":[{"metricId":"test.metric","timestamp":') + '[0-9]+' + Regexp.quote(',"val":5,"min":null,"max":null,"avg":null,"sum":null,"cnt":null},{"metricId":"test.aggregate.metric","timestamp":') + '[0-9]+' + Regexp.quote(',"val":1,"min":null,"max":null,"avg":null,"sum":null,"cnt":null}],"tags":null,"attributes":null}]')
    )))
    @metric_aggregator.sendMetrics
  end
end
