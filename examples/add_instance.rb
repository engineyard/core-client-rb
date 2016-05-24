#!/usr/bin/env ruby

# Very basic example of how to add an instance to a given environment.
# As is attempts to add a t2.micro, see new_server_specs below.
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: add_instance.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-n', '--iname NAME', 'Instance name') { |v| options[:instance_name] = v }
  opts.on('-r', '--irole ROLE', 'Instance role (app, util)') { |v| options[:instance_role] = v }
  
end.parse!

# Token comes for `~/.eyrc`
client = Ey::Core::Client.new(token: "abcdefghijklmnrstuvwxyz123456789")

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

# Instance's name
instance_name = options[:instance_name]

puts "Adding app instance #{instance_name} to environment #{environment.name}...."

# TO DO:  read new_server_specs from a file provided as a parameter
new_server_specs = {
        :environment     => environment.id,
        :flavor_id       => "t2_micro",
        :mnt_volume_size => "10",
        :name            => instance_name,
        :role            => options[:instance_role],
        :volume_size     => "10",
}

provision_request = client.servers.create(new_server_specs)
if !provision_request then
  puts "Provision request FAILED!!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

while !provision_request.ready? do
  print "."
  provision_request.reload
  sleep 20
end
puts "*"
puts "Instance provisioned successfully"
puts "-------------------"

puts "Waiting for instance #{instance_name} to integrate into the environment #{environment.name}...."
new_server = environment.servers.first(name: new_server_specs[:name])
while new_server.state == "integrating" do
  print "."
  new_server.reload
  sleep 20
end
puts "*"
puts "-------------------"

if !new_server.enabled? then
  puts "Adding of instance #{instance_name} into environment #{environment.name} FAILED!!!"
  puts "Check cloud.engineyard.com for more details"
  exit
end

puts "Adding of instance #{instance_name} into environment #{environment.name} SUCCEEDED!!!"



