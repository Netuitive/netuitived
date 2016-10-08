require 'netuitive/netuitived_config_manager'
require 'netuitive/scheduler'
require 'drb/drb'
require 'netuitive/netuitived_server'

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
      @front_object ||= NetuitivedServer.new
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
        Scheduler.startSchedule
        DRb.start_service(server_uri, front_object)
        DRb.thread.join
      end

      if foreground
        runner.call
      else
        fork(&runner)
        puts 'netuitived started'
      end
    end

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
      ConfigManager.setup unless @config_manager_setup

      @config_manager_setup = true
      @server_uri ||= "druby://#{ConfigManager.netuitivedAddr}:#{ConfigManager.netuitivedPort}".freeze
    end
  end
end
