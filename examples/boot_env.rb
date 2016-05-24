#!/usr/bin/env ruby

# Very basic example of how to boot a given environment from a blueprint
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: boot_env.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-b', '--blueprint NAME', 'Blueprint name') { |v| options[:blueprint_name] = v }

end.parse!

# Token comes for `~/.eyrc`
client = Ey::Core::Client.new(token: "abcdefghijklmnrstuvwxyz123456789")

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

if environment.servers.count > 0 then
  puts "Environment has instances running, are you sure you want to boot it?"
  exit
end

# Get blueprint's name for cloud.engineyard.com
blueprint = environment.blueprints.first(name: options[:blueprint_name])
if !blueprint then
  puts "Could not find the specified blueprint."
  puts "Check cloud.engineyard.com for more details."
  exit
end
  
env_options = {"blueprint_id": blueprint.id}
puts "Booting environment using an specific blueprint...."
provision_request = environment.boot(env_options)
while !provision_request.ready? do
  print "."
  provision_request.reload
  sleep 20
end
puts "*"

puts "-------------------"
if !provision_request.successful? then
  puts "Boot environment FAILED!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

puts "Boot environment SUCCEDED!!!"
