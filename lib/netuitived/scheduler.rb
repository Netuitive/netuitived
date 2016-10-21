module NetuitiveD
  class Scheduler
    def self.startSchedule
      Thread.new do
        loop do
          NetuitiveD::NetuitiveLogger.log.debug "scheduler sleeping for: #{NetuitiveD::ConfigManager.interval}"
          sleep(NetuitiveD::ConfigManager.interval)
          Thread.new do
            NetuitiveD::ErrorLogger.guard('exception during schedule') do
              NetuitiveD::NetuitiveLogger.log.debug 'scheduler sending metrics'
              Netuitived.front_object.sendMetrics
              NetuitiveD::NetuitiveLogger.log.debug 'scheduler sent metrics'
            end
          end
        end
      end
    end
  end
end
