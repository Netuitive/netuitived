module NetuitiveD
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
    class << self
      attr_reader :log
      def setup
        file = NetuitiveD::ConfigManager.property('logLocation', 'NETUITIVED_LOG_LOCATION', "#{File.expand_path('../../..', __FILE__)}/log/netuitive.log")
        age = NetuitiveD::ConfigManager.property('logAge', 'NETUITIVED_LOG_AGE', 'daily')
        size = NetuitiveD::ConfigManager.property('logSize', 'NETUITIVED_LOG_SIZE', nil)
        @log = NetuitiveD::Logger.new(file, age, size)
      rescue
        puts 'netuitive unable to open log file'
        @log = NetuitiveD::CheaterLogger.new
      end
    end
  end
end
