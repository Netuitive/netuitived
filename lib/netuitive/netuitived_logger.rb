require 'logger'
class CheaterLogger
	attr_accessor :level
	def debug(message)
	end
	def error(message)
	end
	def info(message)
	end
end

class NetuitiveLogger
	begin
		@@log = Logger.new("#{File.expand_path("../../..", __FILE__)}/log/netuitive.log",'daily', 10)
	rescue
		puts "netuitive unable to open log file"
		@@log = CheaterLogger.new
	end
	class << self
		def log
			return @@log
		end
	end
end