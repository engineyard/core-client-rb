require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Kubey < Belafonte::App
        title "kubey"
        summary "Perform Operations on Kubernetes clusters"

        class List < Subcommand
          include Ey::Core::Cli::Helpers::StreamPrinter
          title "list"
          summary "List Kubernetes clusters"

          def handle
            stream_print("ID" => 10, "Name" => 50, "Masters" => 7, "Nodes" => 7) do |printer|
              core_environments(kubey: true).each_entry do |env|
                servers_by_role = Hash.new{|h,k| h[k] = 0}
                env.servers.each{ |s| servers_by_role[s.role] += 1 }
                #TODO: show in-progress requests too!
                #TODO: show recently failed requests too? (only the absolute most recent?)
                printer.print(env.id, env.name, servers_by_role["kubey_master"], servers_by_role["kubey_node"])
              end
            end
          end
        end
        mount List

        class Create < Subcommand
          title "create"
          summary "Create a Kubernetes clusters"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          option :ip,
            long: 'ip',
            description: 'IP address or ID',
            argument: 'IP'

          option :name,
            short: ['n'],
            long: ['name'],
            description: 'Name for new cluster',
            argument: 'Name'

          option :region,
            short: ['r','l'],
            long: ['region','location'],
            description: 'AWS Region for new cluster',
            argument: 'Region'

          option :instance_size,
            short: ['s','t'],
            long: ['size','instance-size','instance-type'],
            description: "AWS instance type (API Name), default is m3.large",
            argument: "Instance Size/Type"

          def handle
            name = options[:name] || "kubey_" + SecureRandom.hex(8)
            region = options[:region] || "us-east-1"
            instance_size = options[:instance_size] || "m3.large"
            #TODO: validate region against known list of regions? (known list of VPC regions), output suggestions
            account = core_account
            unless account
              raise "No Accounts"
            end
            if account.providers.empty?
              raise "Account #{account.name} does not have an Amazon Account setup yet. To setup your amazon account go to: TODO"
            end
            #TODO: validation that region must be default VPC???
            #TODO: support specifying instance size (different size for master vs nodes)


            #TODO: handle validation of invalid flavor and show:
            # accounts.first(name: "staging-berkeley").providers.first.provider_locations.first.compute_flavors

            e = core_client.environments.create!({
              account_id: account.id,
              name: name,
              kubey: true,
              region: region,
            })
            boot_configuration = {
              type: :kubey,
              kubey_node_count: 2,
              instance_size: instance_size,
            }
            if ip_identifier = options[:ip]
              #TODO: avoid specifying an IP connected to an in-progress boot request.. If we do, will it fail appropriately?
              if found_ip = account.addresses.get(ip_identifier) ||
                            account.addresses.first(ip_address: ip_identifier)
              then
                if found_ip.server
                  ap found_ip.server
                  raise "IP already attached to a running server" #TODO: better identify the running server
                end
                boot_configuration[:ip_id] = found_ip.id
              else
                raise "IP not found '#{ip_identifier}'"
              end
            end
            req = begin
              e.boot(:configuration => boot_configuration)
            rescue Ey::Core::Response::Unprocessable => ex
              puts ex.message
              if ex.message.match(/Too many provisioned addresses/)
                existing_ips = account.addresses.all(location: region).select{|ip| ip.server.nil? }
                puts "Try specifying an IP. e.g. --ip #{existing_ips.first.ip_address}"
              end
              raise ex
            end
            puts "Booting cluster: #{name} (ID: #{e.id})"
          end
        end
        mount Create

        class Status < Subcommand
          title "status"
          summary "Get status/info about a Kubernetes cluster"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          def handle
            environment = core_environment(kubey: true, arg_name: :cluster)
            puts "Cluster: #{environment.name} (ID: #{environment.id})"
            if environment.servers.empty?
              puts "(No Servers Running)"
            end
            environment.servers.each do |s|
              puts [s.provisioned_id,
                    s.flavor_id,
                    s.state,
                    s.role,
                    s.private_hostname,
                    s.public_hostname ].join(" -- ")
            end
          end
        end
        mount Status

        class GetCredentials < Subcommand
          title "get-credentials"
          summary "Get credentials for a Kubernetes environment"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          def handle
            environment = core_environment(kubey: true, arg_name: :cluster)
            puts "Cluster: #{environment.name} (ID: #{environment.id})"
            #TODO: if environment.kubey_cluster is nil, display some sort of error message with useful recourse?
            kubey_cluster = environment.kubey_cluster
            # ap environment.kubey_cluster
            unless kubey_cluster
              raise "Kubernetes Cluster setup has not completed (or failed)"
            end
            unless kubey_cluster.client_certificate
              raise "Kubernetes Cluster setup has not completed (or failed) -- certs not yet generated"
            end
            #TODO: distinguish between cluster where setup is in-progress and setup has failed
            config_path = File.expand_path("~/.kube/config")
            #TODO: option to abort if config file already exists
            #TODO: option to just output the config file contents to STDOUT
            config_hash = kubey_cluster.kube_config(environment.name)
            if File.exists?(config_path)
              #merge
              #TODO: if the merge! would overrwite something warn, and respect a command line arg to abort if such an overwrite would happen (or expect a --force CLI arg?)
              puts "Merging config into #{config_path}"
              new_config = config_hash
              existing_config = YAML.load_file(config_path)
              merged_config = new_config.merge(existing_config)

              smart_merge = Proc.new do |key|
                new_entry = new_config[key].first
                if conflict = merged_config[key].detect{|entry| entry["name"] == new_entry["name"]}
                  #TODO: output warning about deleted conflict?
                  merged_config[key].delete(conflict)
                end
                merged_config[key] << new_entry
              end
              smart_merge.call("users")
              smart_merge.call("contexts")
              smart_merge.call("clusters")
              if merged_config["current-context"] != new_config["current-context"]
                puts "WARNING: changing kubectl current_context to #{new_config["current-context"]} (WAS #{merged_config["current-context"]})"
                #TODO: output info about how to switch current_context with a kubectl command
                merged_config["current-context"] = new_config["current-context"]
              end
              File.open(config_path, "w+"){|fp| fp.write(merged_config.to_yaml)}
              #TODO: don't overwrite the value of 'current-context'?
              #TODO: output the kubectl command for swithing contexts??
            else
              #create
              puts "Creating config file at #{config_path}"
              FileUtils.mkdir_p(File.expand_path("..", config_path))
              File.open(config_path, "w+"){|fp| fp.write(config_hash.to_yaml)}
            end
          end
        end
        mount GetCredentials

        class Fix < Subcommand
          title "fix"
          summary "Attempt to fix a Kubernetes cluster (AKA re-run chef setup scripts on all instances in hopes it will 'do the right thing')"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          def handle
            #TODO: handle error of apply already in progress
            environment = core_environment(kubey: true, arg_name: :cluster)
            environment.update(release_label: environment.release_label.gsub(/[^.]+$/,"latest")) #TODO: updating to latest release should be optional... command-line option to control it ... 
            #TODO: default should be DON'T update, but output a message about being outdated stack version if we are and name the optional command line arg to let the user also update to latest version
            environment.apply
            puts "Re-Running chef configuration scripts on #{environment.servers.size} servers on #{environment.name} (ID: #{environment.id}). Use status to command to poll for completion."
          end
        end
        mount Fix

        class Delete < Subcommand
          title "delete"
          summary "Delete a cluster, shut it down first if it's running"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          def handle
            environment = core_environment(kubey: true, arg_name: :cluster)
            environment.destroy!
            puts "Deleted: #{environment.name} (ID: #{environment.id})"
            #TODO: deleting an environment returns immediately but doens't complete immediately, show pending-deletion status in list somehow
          end
        end
        mount Delete

        #TODO: add/remove command 

      end
    end
  end
end
