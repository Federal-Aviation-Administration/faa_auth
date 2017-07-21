require 'dotenv'
Dotenv.load
require 'capybara'
require 'capybara/sessionkeeper'
require 'highline/import'
begin
  require 'byebug'
rescue LoadError
end


require_relative "faa_auth/version"
require_relative "faa_auth/extensions/common_extension"
require_relative "faa_auth/extensions/session_extension"
require_relative "faa_auth/faa_info"
require_relative "faa_auth/capybara"
require_relative "faa_auth/converter"
require_relative "faa_auth/client"




module FaaAuth

end
