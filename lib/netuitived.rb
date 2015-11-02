require 'netuitive/netuitived_config_manager'
require 'netuitive/scheduler'
require 'drb/drb'
require 'netuitive/netuitived_server'
fork do
	ConfigManager::setup
	Scheduler::startSchedule
	URI="druby://#{ConfigManager.netuitivedAddr}:#{ConfigManager.netuitivedPort}"
	FRONT_OBJECT=NetuitivedServer.new 
	DRb.start_service(URI, FRONT_OBJECT)
	DRb.thread.join
end