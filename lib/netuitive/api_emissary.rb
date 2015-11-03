require 'net/http'
require 'json'
require 'netuitive/netuitived_config_manager'
class APIEmissary
	def sendElements(elementString)
		if ConfigManager.isDebug?
			puts elementString
		end
		req = Net::HTTP::Post.new("/ingest/#{ConfigManager.apiId}", initheader = {'Content-Type' =>'application/json'})
		req.body = elementString
		if ConfigManager.isDebug?
			puts  "starting post"
		end
		if ConfigManager.port =~ /(.*)nil(.*)/
			port = nil
		else
			port = ConfigManager.port.to_int
		end
		response = Net::HTTP.start("#{ConfigManager.baseAddr}", port, :use_ssl => true, :read_timeout => 30, :open_timeout => 30) do |http|
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.ssl_version = :SSLv3
			http.request req
		end
		if ConfigManager.isDebug?
			puts  "post finished"
		end
		if (response.code != "202" and ConfigManager.isError?) or (ConfigManager.isInfo?)
			puts "Response from submitting netuitive metrics to api
			code: #{response.code}
			message: #{response.message}
			body: #{response.body}"
		end
	end
end
