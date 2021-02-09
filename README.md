NetuitiveD
===========

NetuitiveD is a dRuby application submits and aggregates metrics through the use of DRbObjects. NetuitiveD is meant to work in conjunction with the [netuitive_ruby_api](https://rubygems.org/gems/netuitive_ruby_api) and [netuitive_rails_agent](https://rubygems.org/gems/netuitive_rails_agent) gems to help [Virtana](https://www.virtana.com/products/cloudwisdom/) monitor your Ruby applications.

For more information on NetuitiveD, see our Ruby agent [help docs](https://docs.virtana.com/en/ruby-agent.html), or contact Netuitive support at [cloudwisdom.support@virtana.com](mailto:cloudwisdom.support@virtana.com).

Installing and Running NetuitiveD
---------------------------------

### Install

     gem install netuitived

### Run

1. Run the start script (make sure the user using the command has access rights to the
gem's install directory):

	   netuitived start

1. The start script will prompt you for an API key and an element name. You can get an API key from creating a Ruby datasource in [Netuitive](https://app.netuitive.com/auth/login).

        please enter an element name:
        my_app_name
        please enter an api key:
        DEMOab681D46bf5616dba8337c85DEMO

    If you're unsure about what element name you should use, just use the name of your Ruby application.

>**Note:** The extra config information is found in config/agent.yml. Each field in the config file can also be set using environment variables.

### Test

To run the tests and code syntax validation run the following commands:

```
gem install bundle
bundle install
bundle exec rubocop
bundle exec rake test
```
