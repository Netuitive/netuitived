module NetuitiveD
  class Scheduler
    def self.startSchedule
      Thread.new do
        loop do
          sleep(NetuitiveD::ConfigManager.interval)
          Thread.new do
            Netuitived.front_object.sendMetrics
          end
        end
      end
    end
  end
end
