#!/usr/bin/env ruby

# Very basic example of how to run chef on a single instance in a given environment.
# Requires early access "Individual Instance Update" feature, see: https://support.cloud.engineyard.com/hc/en-us/articles/205413958-Use-Instance-Update-on-Engine-Yard
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: apply_instance.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-i', '--instance_id NAME', 'Instance ID') { |v| options[:instance_id] = v }

end.parse!

# Token comes from '~/.eyrc'
eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

client = Ey::Core::Client.new(token: eyrc['api_token'])

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

# Instance's ID
instance_id = options[:instance_id]

servers = environment.servers.select{|s| s.provisioned_id == instance_id}
if !servers then
  puts "Couldn't find instance #{instance_id} on environment #{environment.name}!!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

server = servers[0]

# Run chef
puts "Running chef on instance #{instance_id} on environment #{environment.name}...."
server.apply
