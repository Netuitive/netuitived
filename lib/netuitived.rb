fork do
	require 'netuitive/netuitived_config_manager'
	require 'netuitive/scheduler'
	require 'drb/drb'
	require 'netuitive/netuitived_server'
	ConfigManager::setup
	Scheduler::startSchedule
	NETUITIVE_URI="druby://#{ConfigManager.netuitivedAddr}:#{ConfigManager.netuitivedPort}"
	FRONT_OBJECT=NetuitivedServer.new 
	DRb.start_service(NETUITIVE_URI, FRONT_OBJECT)
	DRb.thread.join
end