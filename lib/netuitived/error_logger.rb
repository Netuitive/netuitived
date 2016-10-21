# Important! ruby rescue logic is expensive.
# This class is *intended* to be used as a catch all, because we don't want any errors to not be logged
# That *doesn't* mean we should be throwing exceptions rather than guarding against them
# From the benchmarks I've read it seems like rescues are free if no exception is thrown
module NetuitiveD
  class ErrorLogger
    class << self
      def guard(message)
        yield
      rescue => e
        NetuitiveD::NetuitiveLogger.log.error format_exception(e, message)
      end

      def format_exception(exception, *message)
        message = '' unless defined? message || message.nil?
        "#{message} \n\tException message: #{exception.message}\n\t Backtrace: #{exception.backtrace.join("\n\t")}"
      end
    end
  end
end
