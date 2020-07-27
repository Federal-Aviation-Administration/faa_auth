require 'dotenv'
Dotenv.load
require 'capybara'
require 'capybara/sessionkeeper'
require 'highline/import'
begin
  require 'byebug'
rescue LoadError
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

require 'webdrivers'
chrome = ENV['CHROME_PATH'] || which('chrome')
puts "Using chrome: #{chrome}"
Selenium::WebDriver::Chrome.path = chrome


require_relative "faa_auth/version"
require_relative "faa_auth/extensions/common_extension"
require_relative "faa_auth/extensions/session_extension"
require_relative "faa_auth/faa_info"
require_relative "faa_auth/capybara"
require_relative "faa_auth/converter"
require_relative "faa_auth/client"




module FaaAuth

end
