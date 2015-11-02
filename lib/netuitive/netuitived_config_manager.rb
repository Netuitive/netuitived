require 'yaml'
class ConfigManager

	class << self
		def setup()
			@@error=0
			@@info=1
			@@debug=2
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

		def isDebug?
			if @@debugLevel >= @@debug
				return true
			end
			return false
		end

		def isInfo?
			if @@debugLevel >= @@info
				return true
			end
			return false
		end

		def isError?
			if @@debugLevel >= @@error
				return true
			end
			return false
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
			puts "port: #{@@netuitivedPort}"
			puts "addr: #{@@netuitivedAddr}"
			debugLevelString=data["debugLevel"]
			if debugLevelString == "error"
				@@debugLevel=@@error
			elsif debugLevelString == "info"
				@@debugLevel=@@info
			elsif debugLevelString == "debug"
				@@debugLevel=@@debug
			else
				@@debugLevel=@@error
			end

			if isDebug?
				puts "read config file. Results: 
				apiId: #{apiId}
				baseAddr: #{baseAddr}
				port: #{port}
				elementName: #{elementName}
				debugLevel: #{debugLevelString}"
			end
		end
	end
end 
