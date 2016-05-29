#!/usr/bin/env ruby

# Very basic example of how to terminate a given instance in a given environment.
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: terminate_instance.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-n', '--iname NAME', 'Instance name') { |v| options[:instance_name] = v }

end.parse!

# Token comes from '~/.eyrc'
eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

client = Ey::Core::Client.new(token: eyrc['api_token'])

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

# Instance's name
instance_name = options[:instance_name]

puts "Terminating instance #{instance_name} on environment #{environment.name}...."

servers = environment.servers.select{|s| s.name == instance_name}
if !servers then
  puts "Couldn't find instance #{instance_name} on environment #{environment.name}!!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

server = servers[0]
deprovision_request = server.destroy
if !deprovision_request then
  puts "Termination of instance #{instance_name} FAILED!!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

# Terminating the instance with a timeout of 1200sec (20min) as a ballpark figure.
# Adjust as necessary depending of the size/role of the instance.
deprovision_request.ready!(1200)

puts "*"
puts "Instance #{instance_name} terminated successfully"
puts "-------------------"

