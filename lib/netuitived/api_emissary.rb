module NetuitiveD
  class APIEmissary
    def sendElements(elementString)
      NetuitiveD::NetuitiveLogger.log.debug 'start sending elements'
      send("/ingest/ruby/#{NetuitiveD::ConfigManager.apiId}", elementString)
      NetuitiveD::NetuitiveLogger.log.debug 'finish sending elements'
    end

    def sendEvents(eventString)
      NetuitiveD::NetuitiveLogger.log.debug 'finish sending events'
      send("/ingest/events/ruby/#{NetuitiveD::ConfigManager.apiId}", eventString)
      NetuitiveD::NetuitiveLogger.log.debug 'finish sending events'
    end

    def send(uri, body)
      NetuitiveD::NetuitiveLogger.log.debug "post body: #{body}"
      req = Net::HTTP::Post.new(uri.to_s, 'Content-Type' => 'application/json')
      req.body = body
      NetuitiveD::NetuitiveLogger.log.debug 'starting post'
      begin
      port = if NetuitiveD::ConfigManager.port =~ /(.*)nil(.*)/
               nil
             else
               NetuitiveD::ConfigManager.port.to_int
             end
      NetuitiveD::NetuitiveLogger.log.debug "port: #{port}"
      NetuitiveD::NetuitiveLogger.log.debug "path: #{req.path}"
      NetuitiveD::NetuitiveLogger.log.debug "addr: #{NetuitiveD::ConfigManager.baseAddr}"
      response = Net::HTTP.start(NetuitiveD::ConfigManager.baseAddr.to_s, port, use_ssl: true, read_timeout: 30, open_timeout: 30) do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3
        http.request req
      end
      NetuitiveD::NetuitiveLogger.log.debug 'post finished'
      if response.code.to_s != '202' && response.code.to_s != '200'
        NetuitiveD::NetuitiveLogger.log.error "Response from submitting netuitive metrics to api
        code: #{response.code}
        message: #{response.message}
        body: #{response.body}"
      else
        NetuitiveD::NetuitiveLogger.log.info "Response from submitting netuitive metrics to api
        code: #{response.code}
        message: #{response.message}
        body: #{response.body}"
      end
    rescue => exception
      NetuitiveD::NetuitiveLogger.log.error 'error with http post: '
      NetuitiveD::NetuitiveLogger.log.error exception.message
      NetuitiveD::NetuitiveLogger.log.error exception.backtrace
    end
    end
  end
end
