module NetuitiveD
  class CheaterLogger
    attr_accessor :level
    def debug(message); end

    def error(message); end

    def info(message); end
  end

  class NetuitiveLogger
    class << self
      attr_accessor :log
      def setup
        file = NetuitiveD::ConfigManager.property('logLocation', 'NETUITIVED_LOG_LOCATION', "#{File.expand_path('../../..', __FILE__)}/log/netuitive.log")
        age = NetuitiveD::ConfigManager.property('logAge', 'NETUITIVED_LOG_AGE', 'daily')
        age = NetuitiveD::NetuitiveLogger.format_age(age)
        size = NetuitiveD::ConfigManager.property('logSize', 'NETUITIVED_LOG_SIZE', 1_000_000)
        size = NetuitiveD::NetuitiveLogger.format_size(size)
        NetuitiveD::NetuitiveLogger.log = Logger.new(file, age, size)
      rescue => e
        puts 'netuitive unable to open log file'
        puts "error: #{e.message}"
        NetuitiveD::NetuitiveLogger.log = NetuitiveD::CheaterLogger.new
      end

      def format_age(age)
        return 'daily' if age.nil?
        begin
          Integer(age)
        rescue
          age
        end
      end

      def format_size(size)
        return 1_000_000 if size.nil?
        begin
          Integer(size)
        rescue
          size
        end
      end
    end
  end
end
