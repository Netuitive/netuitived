# netuitived
a druby application that allows for the submission and aggregation of metrics through the use of DRbObjects

How to install using gem:

run the command:

     gem install netuitived

How to run:

Once the gem has been installed run the start script (make sure the user it's being run as has access rights to the gem's install directory):

	netuitived start

The start script will prompt you for the API key (which is found from generating a datasource in the Netuitive ui) and the element name (if unsure what to put, just put the name of your ruby application)

That's it, you're up and running. The extra config information is found in config/agent.yml. Each field in the config file can also be set using environment variables. 

This daemon is meant to be used in conjunction with the netuitive_ruby_api (https://rubygems.org/gems/netuitive_ruby_api) and netuitive_rails_agent (https://rubygems.org/gems/netuitive_rails_agent) gems.
