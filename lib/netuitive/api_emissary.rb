require 'net/http'
require 'json'
require 'netuitive/ruby_config_manager'
class APIEmissary
	def sendElements(elements)
		if ConfigManager.isDebug?
			puts elements.to_json
		end
		req = Net::HTTP::Post.new("/ingest/#{ConfigManager.apiId}", initheader = {'Content-Type' =>'application/json'})
		req.body = elements.to_json
		if ConfigManager.isDebug?
			puts  "starting post"
		end
		response = Net::HTTP.start("#{ConfigManager.baseAddr}", ConfigManager.port, :use_ssl => true) do |http|
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
