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
			gem_root= File.expand_path("../../..", __FILE__)
			data=YAML.load_file "#{gem_root}/config/agent.yml"
			@@apiId=data["apiId"]
			@@baseAddr=data["baseAddr"]
			@@port=data["port"]
			@@elementName=data["elementName"]
			@@netuitivedAddr=data["netuitivedAddr"]
			@@netuitivedPort=data["netuitivedPort"]
			@@interval=data["interval"]
			NetuitiveLogger.log.info "port: #{@@netuitivedPort}"
			NetuitiveLogger.log.info "addr: #{@@netuitivedAddr}"
			debugLevelString=data["debugLevel"]
			if debugLevelString == "error"
				NetuitiveLogger.log.level = Logger::ERROR
			elsif debugLevelString == "info"
				NetuitiveLogger.log.level = Logger::INFO
			elsif debugLevelString == "debug"
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
