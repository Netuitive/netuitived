require 'logger'
class NetuitiveLogger
	@@log = Logger.new("#{File.expand_path("../../..", __FILE__)}/log/netuitive.log",'daily', 10)
	class << self
		def log
			return @@log
		end
	end
end