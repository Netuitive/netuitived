require 'netuitive/netuitived_config_manager'
require 'drb/drb'

class Scheduler
  def self.startSchedule
    Thread.new do
      loop do
        sleep(ConfigManager.interval)
        Thread.new do
          Netuitived.front_object.sendMetrics
        end
      end
    end
  end
end
