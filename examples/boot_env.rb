#!/usr/bin/env ruby

# Very basic example of how to boot a given environment from a blueprint
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: boot_env.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-b', '--blueprint NAME', 'Blueprint name') { |v| options[:blueprint_name] = v }

end.parse!

# Token comes from '~/.eyrc'
eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

#client = Ey::Core::Client.new(token: "abcdefghijklmnrstuvwxyz123456789")
client = Ey::Core::Client.new(token: eyrc['api_token'])

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
  
env_options = { "blueprint_id" => blueprint.id }
puts "Booting environment using an specific blueprint...."
provision_request = environment.boot(env_options)

# Booting the environment instance with a timeout of 1800sec (30mins).
# Adjust as necessary depending of the size of the environment.
provision_request.ready!(1800)

puts "-------------------"
if !provision_request.successful? then
  puts "Boot environment FAILED!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

puts "Boot environment SUCCEDED!!!"
