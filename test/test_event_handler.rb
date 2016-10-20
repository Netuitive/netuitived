require 'test/unit'
require 'mocha/test_unit'
require 'json'
require 'netuitived/error_logger'
require 'netuitived/event_handler'
require 'netuitived/netuitive_logger'
require 'netuitived/api_emissary'
require 'netuitived/ingest_tag'
require 'netuitived/ingest_metric'
require 'netuitived/ingest_sample'
require 'netuitived/ingest_element'
require 'netuitived/ingest_event'
require 'netuitived/config_manager'
require 'netuitived/metric_aggregator'

module NetuitiveD
  class EventHandlerTest < Test::Unit::TestCase
    def setup
      @api_emissary = mock
      @event_handler = NetuitiveD::EventHandler.new(@api_emissary)
      NetuitiveD::NetuitiveLogger.setup
    end

    def test_handle_event
      @api_emissary.expects(:sendEvents).once.with(regexp_matches(Regexp.new(Regexp.quote('[{"source":"test source","timestamp":') + '[0-9]+' + Regexp.quote(',"title":"test title","type":"test type","tags":[{"name":"test name","value":"test value"}],"data":{"elementId":null,"level":"info","message":"test_message"}}]'))))
      @event_handler.handleEvent('test_message', Time.new(2000, 1, 1, 1, 1, 1), 'test title', 'info', 'test source', 'test type', [NetuitiveD::IngestTag.new('test name', 'test value')])
    end

    def test_handle_exception_event
      @api_emissary.expects(:sendEvents).once.with(regexp_matches(Regexp.new(Regexp.quote('[{"source":"Ruby Agent","timestamp":') + '[0-9]+' + Regexp.quote(',"title":"Ruby Exception","type":"INFO","tags":[{"name":"test_name","value":"test_value"},{"name":"Exception","value":"RuntimeError"}],"data":{"elementId":null,"level":"Warning","message":"Exception Message: test exception') + '..test_name:\ test_value..Exception:\ RuntimeError..Backtrace:.*' + Regexp.quote('}}]'))))
      begin
        raise 'test exception'
      rescue => e
        @event_handler.handleExceptionEvent({ message: e.message, backtrace: e.backtrace.join("\n\t") }, e.class, test_name: 'test_value')
      end
    end
  end
end
