require 'net/http'
require 'json'
require 'netuitive/netuitived_config_manager'
require 'netuitive/netuitived_logger'
class APIEmissary
  def sendElements(elementString)
    NetuitiveLogger.log.debug "start sending elements"
    send("/ingest/ruby/#{ConfigManager.apiId}", elementString)
    NetuitiveLogger.log.debug "finish sending elements"
  end
  def sendEvents(eventString)
    NetuitiveLogger.log.debug "finish sending events"
    send("/ingest/events/ruby/#{ConfigManager.apiId}", eventString)
    NetuitiveLogger.log.debug "finish sending events"
  end
  def send(uri, body)
    NetuitiveLogger.log.debug "post body: #{body}"
    req = Net::HTTP::Post.new("#{uri}", initheader = {'Content-Type' => 'application/json'})
    req.body = body
    NetuitiveLogger.log.debug "starting post"
    begin
      if ConfigManager.port =~ /(.*)nil(.*)/
        port = nil
      else
        port = ConfigManager.port.to_int
      end
      NetuitiveLogger.log.debug "port: #{port}"
      NetuitiveLogger.log.debug "path: #{req.path}"
      NetuitiveLogger.log.debug "addr: #{ConfigManager.baseAddr}"
      response = Net::HTTP.start("#{ConfigManager.baseAddr}", port, :use_ssl => true, :read_timeout => 30, :open_timeout => 30) do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3
        http.request req
      end
    rescue => exception
      NetuitiveLogger.log.error "error with http post: "
      NetuitiveLogger.log.error exception.message
      NetuitiveLogger.log.error exception.backtrace
    end
    NetuitiveLogger.log.debug "post finished"
    if (response.code != "202" or response.code != "200")
      NetuitiveLogger.log.error "Response from submitting netuitive metrics to api
      code: #{response.code}
      message: #{response.message}
      body: #{response.body}"
    else
      NetuitiveLogger.log.info "Response from submitting netuitive metrics to api
      code: #{response.code}
      message: #{response.message}
      body: #{response.body}"
    end
  end
end
