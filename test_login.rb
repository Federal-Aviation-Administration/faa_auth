require 'faa_auth'
require 'pry'
client = FaaAuth::Client.new

client.sign_in


binding.pry

puts client
