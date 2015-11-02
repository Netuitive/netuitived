require 'netuitive/netuitived_config_manager'
require 'drb/drb'
class Scheduler
	def self.startSchedule
		Thread.new do
  			while true do
  				sleep(ConfigManager.interval)
    			FRONT_OBJECT.sendMetrics
  			end
		end
	end
end 
