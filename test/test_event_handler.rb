require 'test/unit'
require 'mocha/test_unit'
require 'netuitive/event_handler'
require 'netuitive/netuitived_logger'
require 'netuitive/api_emissary'
require 'netuitive/ingest_tag'

class EventHandlerTest < Test::Unit::TestCase
  def setup
    @api_emissary = mock
    @event_handler = EventHandler.new(@api_emissary)
    NetuitiveLogger.setup
  end

  def test_handle_event
    @api_emissary.expects(:sendEvents).once.with('[{"source":"test source","timestamp":946706461000,"title":"test title","type":"test type","tags":[{"name":"test name","value":"test value"}],"data":{"elementId":null,"level":"info","message":"test_message"}}]')
    @event_handler.handleEvent('test_message', Time.new(2000, 1, 1, 1, 1, 1), 'test title', 'info', 'test source', 'test type', [IngestTag.new('test name', 'test value')])
  end

  def test_handle_exception_event
    @api_emissary.expects(:sendEvents).once.with(regexp_matches(Regexp.new(Regexp.quote('[{"source":"Ruby Agent","timestamp":') + '[0-9]+' + Regexp.quote(',"title":"Ruby Exception","type":"INFO","tags":[{"name":"test_name","value":"test_value"},{"name":"Exception","value":"RuntimeError"}],"data":{"elementId":null,"level":"Warning","message":"Exception Message: test exception') + '..test_name:\ test_value..Exception:\ RuntimeError..Backtrace:.*' + Regexp.quote('}}]'))))
    begin
      raise 'test exception'
    rescue => e
      @event_handler.handleExceptionEvent(e, e.class, test_name: 'test_value')
    end
  end
end
