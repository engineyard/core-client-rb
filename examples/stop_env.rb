#!/usr/bin/env ruby

# Very basic example of how to stop a given environment.
# For more info visit http://developer.engineyard.com 

require 'ey-core'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: stop_env.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }

end.parse!

# Token comes from '~/.eyrc'
eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

client = Ey::Core::Client.new(token: eyrc['api_token'])

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

if environment.servers.count == 0 then
  puts "Environment doesn't have instances running, are you sure it isn't stopped already?"
  exit
end

puts "Stopping environment #{environment.name}...."
deprovision_request = environment.deprovision

# Stoping the environment with a timeout of 1200sec.
# Adjust as necessary depending of the size of the environment.
deprovision_request.ready!(1200)

puts "-------------------"

if !deprovision_request.successful? then 
  puts "Stop environment FAILED!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

puts "Stop environment SUCCEDED!!!"

