require 'json'
class IngestSample
  attr_accessor :metricId, :timestamp, :val, :min, :max, :avg, :sum, :cnt
  def initialize(metricId, timestamp, val, min, max, avg, sum, cnt)
    @metricId = metricId
    @timestamp = timestamp
    @val = val
    @min = min
    @max = max
    @avg = avg
    @sum = sum
    @cnt = cnt
  end

  def to_json(options = {})
    millis = @timestamp.to_f * 1000
    {'metricId' => @metricId,'timestamp' => millis.round, 'val' => @val,'min' => @min, 'max' => @max, 'avg' => @avg,'sum' => @sum, 'cnt' => @cnt}.to_json
  end
end
