require 'yaml'
require 'netuitive/netuitived_logger'
class ConfigManager

  class << self
    def setup()
      readConfig()
    end

    def apiId
      @@apiId
    end

    def baseAddr
      @@baseAddr
    end

    def port
      @@port
    end

    def elementName
      @@elementName
    end

    def netuitivedAddr
      @@netuitivedAddr
    end

    def netuitivedPort
      @@netuitivedPort
    end

    def interval
      @@interval
    end

    def readConfig()
      gem_root = File.expand_path('../../..', __FILE__)
      data = YAML.load_file "#{gem_root}/config/agent.yml"
      @@apiId = ENV['NETUITIVED_API_ID']
      if(@@apiId == nil || @@apiId == '')
        @@apiId = data['apiId']
      end
      @@baseAddr = ENV['NETUITIVED_BASE_ADDR']
      if(@@baseAddr == nil || @@baseAddr == '')
        @@baseAddr = data['baseAddr']
      end
      @@port = ENV['NETUITIVED_PORT']
      if(@@port == nil || @@port == '')
        @@port = data['port']
      end
      @@elementName = ENV['NETUITIVED_ELEMENT_NAME']
      if(@@elementName == nil || @@elementName == '')
        @@elementName = data['elementName']
      end
      @@netuitivedAddr = ENV['NETUITIVED_NETUITIVED_ADDR']
      if(@@netuitivedAddr == nil || @@netuitivedAddr == '')
        @@netuitivedAddr = data['netuitivedAddr']
      end
      @@netuitivedPort = ENV['NETUITIVED_NETUITIVED_PORT']
      if(@@netuitivedPort == nil || @@netuitivedPort == '')
        @@netuitivedPort = data['netuitivedPort']
      end
      @@interval = ENV['NETUITIVED_INTERVAL']
      if(@@interval == nil || @@interval == '')
        @@interval = data['interval']
      end
      debugLevelString = ENV['NETUITIVED_DEBUG_LEVEL']
      if(debugLevelString == nil || debugLevelString == '')
        debugLevelString = data['debugLevel']
      end
      NetuitiveLogger.log.info "port: #{@@netuitivedPort}"
      NetuitiveLogger.log.info "addr: #{@@netuitivedAddr}"
      if debugLevelString == 'error'
        NetuitiveLogger.log.level = Logger::ERROR
      elsif debugLevelString == 'info'
        NetuitiveLogger.log.level = Logger::INFO
      elsif debugLevelString == 'debug'
        NetuitiveLogger.log.level = Logger::DEBUG
      else
        NetuitiveLogger.log.level = Logger::ERROR
      end
      NetuitiveLogger.log.debug "read config file. Results:
        apiId: #{apiId}
        baseAddr: #{baseAddr}
        port: #{port}
        elementName: #{elementName}
        debugLevel: #{debugLevelString}"
    end
  end
end
