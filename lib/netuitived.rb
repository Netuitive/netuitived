require 'drb/drb'
require 'net/http'
require 'json'
require 'yaml'
require 'drb/drb'
require 'logger'
require 'netuitived/config_manager'
require 'netuitived/netuitive_logger'
require 'netuitived/error_logger'
require 'netuitived/ingest_event'
require 'netuitived/ingest_tag'
require 'netuitived/ingest_metric'
require 'netuitived/ingest_sample'
require 'netuitived/ingest_element'
require 'netuitived/netuitived_server'
require 'netuitived/api_emissary'
require 'netuitived/metric_aggregator'
require 'netuitived/event_handler'
require 'netuitived/scheduler'

##
# Provides facilities for running Netuitived
class Netuitived
  class << self
    attr_reader :server_uri

    ##
    # The DRb front object
    #
    # @return [NetuitivedServer] The NetuitivedServer front object
    def front_object
      @front_object ||= new_front_object
    end

    def new_front_object
      apiEmissary = NetuitiveD::APIEmissary.new
      NetuitiveD::NetuitivedServer.new(NetuitiveD::MetricAggregator.new(apiEmissary), NetuitiveD::EventHandler.new(apiEmissary))
    end

    ##
    # Checks that config values are provided and prompts for them if not
    def interactively_check_config
      gem_root = File.expand_path('../..', __FILE__)
      data = YAML.load_file("#{gem_root}/config/agent.yml")

      written = false
      element_name = ENV['NETUITIVED_ELEMENT_NAME'] || data['elementName'] || ''

      if element_name == 'elementName' || element_name == ''
        puts 'please enter an element name: '
        element_name = STDIN.gets.chomp
        data['elementName'] = element_name
        written = true
      end

      api_id = ENV['NETUITIVED_API_ID'] || data['apiId'] || ''

      if api_id == 'apiId' || api_id == ''
        puts 'please enter an api key: '
        api_id = STDIN.gets.chomp
        data['apiId'] = api_id
        written = true
      end

      return unless written

      File.open("#{gem_root}/config/agent.yml", 'w') { |f| f.write data.to_yaml }
    end

    ##
    # Starts netuitived
    #
    # @param foreground [true, false] If true, run netuitived in the foreground
    def start(foreground = false)
      # Maintain the initial setup behavior
      interactively_check_config

      # Load the config from disk into ConfigManager
      load_config

      # Stop the service if it's already running
      stop(true)

      # Create a proc to run netuitived
      runner = proc do
        NetuitiveD::NetuitiveLogger.log.debug 'starting scheduler'
        NetuitiveD::Scheduler.startSchedule
        NetuitiveD::NetuitiveLogger.log.debug 'starting drb service'
        begin
          DRb.start_service(server_uri, front_object)
          DRb.thread.join
        rescue => e
          NetuitiveD::NetuitiveLogger.log.error "drb error: #{e.message} backtrace: #{e.backtrace}"
        end
      end

      if foreground
        puts 'netuitived running'
        runner.call
      else
        fork(&runner)
        puts 'netuitived started'
      end
    end

    ##
    # Stops netuitived if it's running
    #
    # @param suppress_not_running_message [true, false] suppresses the "netuitived isn't running" message
    def stop(suppress_not_running_message = false)
      load_config

      DRb.start_service

      begin
        DRbObject.new_with_uri(@server_uri).stopServer
        puts 'netuitived stopped'
      rescue
        puts "netuitived isn't running" unless suppress_not_running_message
      end
    end

    private

    ##
    # Loads the configuration if necessary
    def load_config
      unless @config_manager_setup
        NetuitiveD::ConfigManager.load_config
        NetuitiveD::NetuitiveLogger.setup
        NetuitiveD::ConfigManager.read_config
      end

      @config_manager_setup = true
      @server_uri ||= "druby://#{NetuitiveD::ConfigManager.netuitivedAddr}:#{NetuitiveD::ConfigManager.netuitivedPort}".freeze
    end
  end
end
