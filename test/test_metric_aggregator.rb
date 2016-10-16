require 'test/unit'
require 'netuitive/metric_aggregator'
require 'netuitive/netuitived_logger'

class MetricAggregatorTest < Test::Unit::TestCase
  def setup
    @metric_aggregator = MetricAggregator.new
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
end
