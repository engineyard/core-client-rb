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
            stream_print("ID" => 10, "Name" => 50, "Region" => 10, "Masters" => 7, "Nodes" => 7) do |printer|
              core_environments(kubey: true).each_entry do |env|
                servers_by_role = Hash.new{|h,k| h[k] = 0}
                env.servers.each{ |s| servers_by_role[s.role] += 1 }
                printer.print(env.id, env.name, env.region, servers_by_role["kubey_master"], servers_by_role["kubey_node"])
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

          option :availability_zone,
            short: ['az','z'],
            long: ['az','zone', 'availability-zone'],
            description: 'AWS Availability Zone for new cluster',
            argument: 'Availability Zone'

          option :additional_availability_zones,
            long: ['additional-zones', 'additional-availability-zones'],
            description: 'AWS Additional Availability Zones for new cluster',
            argument: 'Availability Zones (comma seperated)'

          option :num_nodes,
            long: ['num-nodes', 'node-count'],
            description: 'Number of Worker Nodes to provision is each Availability Zone',
            argument: 'Number'

          option :instance_size,
            short: ['s','t'],
            long: ['size','instance-size','instance-type'],
            description: "AWS instance type (API Name), default is m3.large",
            argument: "Instance Size/Type"

          option :key,
            short: ['k'],
            long: ['key'],
            description: "SSK key to install on all cluster instances",
            argument: "path to public key file"

          option :no_key,
            long: ['no-key'],
            description: "Skip installing SSH keys (boot cluster with no installed SSH keys)",
            argument: "(none)"

          def handle
            if options[:key]
              keys = File.read(options[:key]).split("\n")
            elsif options[:no_key]
              keys = []
            else
              path = File.expand_path("~/.ssh/id_rsa.pub")
              unless File.exists?(path)
                raise "Expected to find SSH public key at #{path}, please specify one with --key. Or explicitly specify --no-key"
              end
              keys = File.read(path).split("\n")
            end
            name = options[:name] || "kubey_" + SecureRandom.hex(8)
            if options[:availability_zone]
              expected_region = options[:availability_zone][0...-1]
              if region_given = options[:region]
                unless region_given == expected_region
                  raise "Specified region: #{region_given} does not match specified AZ #{options[:availability_zone]}"
                end
              end
              options[:region] ||= expected_region
            end
            region = options[:region] || "us-east-1"
            primary_availability_zone = options[:availability_zone] || (region + "a")
            additional_availability_zones = options[:additional_availability_zones].to_s.split(",")
            instance_size = options[:instance_size] || "m3.large"
            num_nodes = (options[:num_nodes] || 2).to_i * (additional_availability_zones.size + 1)
            account = core_account
            unless account
              raise "No Accounts"
            end
            if account.providers.empty?
              raise "Account #{account.name} does not have an Amazon Account setup yet. To setup your amazon account go to: TODO"
            end
            #TODO: support specifying instance size (different size for master vs nodes)
            boot_configuration = {
              type: :kubey,
              kubey_node_count: num_nodes,
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
            begin
              e = core_client.environments.create!({
                account_id: account.id,
                name: name,
                kubey_cluster: {
                  primary_availability_zone: primary_availability_zone,
                  additional_availability_zones: additional_availability_zones,
                },
                region: region,
                boot_request: {
                  configuration: boot_configuration
                },
                keypairs: keys.map{|k| {name: k.split(" ").last, public_key: k}},
              })
              puts "Booting cluster: #{name} (ID: #{e.id})"
            rescue Ey::Core::Response::Unprocessable => ex
              puts ex.message
              if ex.message.match(/Too many provisioned addresses/)
                existing_ips = account.addresses.all(location: region).select{|ip| ip.server.nil? }
                puts "Try specifying an IP. e.g. --ip #{existing_ips.first.ip_address}"
              end
              if ex.message.match(/Instance size is invalid/) || ex.message.match(/Instance size .* has not been enabled/)
                provider_location = account.providers.first.provider_locations.first(location_id: region)
                puts "Instance size unknown or un-supported, try one of:"
                provider_location.compute_flavors.each_entry{|x| puts x.api_name }
              end
              raise ex
            end
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
            if environment.deleted_at
              puts "deleted #{environment.deleted_at}"
            else
              relevant_requests = environment.requests.all(user: true, relevant: true)
              relevant_requests.each_entry do |r|
                puts r.request_status
              end
              if environment.servers.empty?
                puts "(No Servers Running)"
              end
              environment.servers.each do |s|
                puts [s.provisioned_id,
                      s.flavor_id,
                      s.state,
                      s.role,
                      s.location,
                      s.private_hostname,
                      s.public_hostname ].join(" -- ")
                unless s.state.to_s == "running"
                  s.chef_status.to_a.each do |chef_stat|
                    puts "  " + chef_stat['message'] + " -- " + chef_stat['time_ago'] + " ago"
                  end
                end
              end
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
            kubey_cluster = environment.kubey_cluster
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

        class DbListServices < Subcommand
          include Ey::Core::Cli::Helpers::StreamPrinter
          title "db-list-services"
          summary "list database services"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account
            stream_print("ID" => 40, "Name" => 30, "DB Type" => 10, "Region" => 10, "Instance Type" => 17, "Replicas" => 10) do |printer|
              account.database_services.each_entry do |db_service|
                master = db_service.servers.detect{|s| !s.replication_source_url }
                replica_count = db_service.servers.select{|s| s.replication_source_url }.size
                printer.print(db_service.id, db_service.name,
                  master && master.engine,
                  db_service.location,
                  master && master.flavor,
                  replica_count)
                db_service.databases.each_entry do |db|
                  puts " - Database #{db.name} (#{db.id})"
                  connected_environments = []
                  db.environments.all(kubey: true).each_entry{ |env| connected_environments << env }
                  puts " -- #{connected_environments.size} Connected Kubernetes Clusters"
                end
              end
            end
          end
        end
        mount DbListServices

        class DbList < Subcommand
          include Ey::Core::Cli::Helpers::StreamPrinter
          title "db-list"
          summary "list databases"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account
            stream_print("ID" => 40, "Name" => 20, "DB Type" => 10, "Service" => 60, "Clusters" => 10) do |printer|
              account.logical_databases.each_entry do |db|
                db_service = db.service
                master = db_service.servers.detect{|s| !s.replication_source_url }
                connected_environments = []
                db.environments.all(kubey: true).each_entry{ |env| connected_environments << env }
                printer.print(db.id, db.name, master && master.engine, 
                  "#{db_service.id} - #{db_service.name}",
                  connected_environments.size)
              end
            end
          end
        end
        mount DbList


      end
    end
  end
end
