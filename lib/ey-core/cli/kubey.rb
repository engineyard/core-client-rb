require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Kubey < Belafonte::App
        title "kubey"
        summary "Perform Operations on Kubernetes clusters"

        class KubeySubcommand < Subcommand
          def kubey_environment(opts = {})
            if opts[:account].nil?
              opts.delete(:account)
            end
            core_environment(opts.merge(kubey: true, arg_name: :cluster))
          end

          def core_environment(opts = {})
            @_core_environment ||= begin
              argname = opts.delete(:arg_name) || :environment
              arg = options[argname]
              if arg
                found = core_client.environments.first(opts.merge(id: arg)) ||
                        core_client.environments.first(opts.merge(name: arg))
                unless found
                  raise "Couldn't find environment '#{arg}'"
                end
                found
              end
            end
          end

          def core_db_service(opts = {})
            @_core_db_service ||= begin
              argname = opts.delete(:arg_name) || :db_service
              arg = options[argname]
              if arg
                found = core_client.database_services.all(opts).get(arg) ||
                        core_client.database_services.all(opts).first(name: arg)
                unless found
                  raise "Couldn't find database service '#{arg}'"
                end
                found
              end
            end
          end

          def core_environments(opts = {})
            @_core_environments ||= {}
            @_core_environments[opts] ||= begin
              if account = opts.delete(:account)
                account.environments.all(opts)
              else
                core_client.users.current.environments.all(opts)
              end
            end
          end
        end

        class List < KubeySubcommand
          include Ey::Core::Cli::Helpers::StreamPrinter
          title "list"
          summary "List Kubernetes clusters"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account if options[:account]
            account_id = account && account.id
            stream_print("ID" => 10, "Name" => 40, "Region" => 15, "Masters" => 7, "Nodes" => 7, "Databases" => 12) do |printer|
              core_environments(kubey: true, account: account, per_page: 100).each_entry do |env|
                printer.print(env.id, env.name, env.region,
                  env.kubey_master_count, env.kubey_node_count, env.kubey_logical_database_count)
                if env.kubey_master_count > 0 && env.upgrade_available
                  puts "-- Upgrade Available, for details see: #{env.available_upgrade_web_uri}"
                end
              end
            end
          end
        end
        mount List

        class Create < KubeySubcommand
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

          switch :no_key,
            long: ['no-key'],
            description: "Skip installing SSH keys (boot cluster with no installed SSH keys)"

          switch :bridge,
            long: ['bridge'],
            description: "Create a bridge instance too (for kubernetes training)"

          def handle
            if options[:key]
              keys = File.read(options[:key]).split("\n")
            elsif switch_active?(:no_key)
              keys = []
            else
              path = File.expand_path("~/.ssh/id_rsa.pub")
              unless File.exists?(path)
                raise "Expected to find SSH public key at #{path}, please specify one with --key. Or explicitly specify --no-key"
              end
              keys = File.read(path).split("\n")
            end
            name = options[:name] || raise("please specify a name for your cluster (--name)")
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
            if switch_active?(:bridge)
              boot_configuration[:kubey_bridge] = true
            end
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

        class Status < KubeySubcommand
          title "status"
          summary "Get status/info about a Kubernetes cluster"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account if options[:account]
            account_id = account && account.id
            environments = []
            if options[:cluster]
              environments = [kubey_environment(account: account_id)]
            elsif account
              environments = core_environments(kubey: true, account: account)
            end
            if environments.empty?
              raise "No Environments found"
            end
            environments.each_with_index do |environment, index|
              if index > 0
                puts
              end
              puts "Cluster: #{environment.name} (ID: #{environment.id})"
              if environment.deleted_at
                puts "deleted #{environment.deleted_at}"
              else
                relevant_requests = environment.requests.all(user: true, relevant: true)
                relevant_requests.each_entry do |r|
                  puts r.request_status
                end
                puts "Servers:"
                no_servers = true
                environment.servers.each_entry do |s|
                  no_servers = false
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
                if no_servers
                  puts "(none)"
                end
                puts "Connected Databases:"
                grouped_by_db_services = Hash.new{|h,k| h[k] = []}
                environment.logical_databases.each_entry do |db|
                  db_service_info = [
                    "#{db.db_service_name} (#{db.db_service_id})",
                    db.db_engine_type,
                    db.db_master_flavor.to_s + (db.db_master_multi_az && " (multi-az)" || ""),
                    "#{db.db_replica_count} replicas",
                  ].join(" -- ")
                  grouped_by_db_services[db_service_info] << db.name
                end
                if grouped_by_db_services.empty?
                  puts "(none)"
                else
                  grouped_by_db_services.each do |db_service_info, logical_dbs|
                    puts "Service: " + db_service_info
                    puts "  DBs: " + logical_dbs.join(", ")
                  end
                end
                if environment.kubey_master_count > 0 && environment.upgrade_available
                  puts "-- Upgrade Available, for details see: #{environment.available_upgrade_web_uri}"
                end
              end
            end
          end

        end
        mount Status

        class GetCredentials < KubeySubcommand
          title "get-credentials"
          summary "Get credentials for a Kubernetes environment"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account if options[:account]
            account_id = account && account.id

            environment = kubey_environment(account: account_id)

            # environment = core_environment(account: account_id)
            #
            # if options[:cluster]
            #   environments = [kubey_environment(account: account_id)]
            # elsif account
            #   environments = core_environments(kubey: true, account: account)
            # end

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

        class Fix < KubeySubcommand
          title "fix"
          summary "Attempt to fix a Kubernetes cluster (AKA re-run chef setup scripts on all instances in hopes it will 'do the right thing')"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account if options[:account]
            account_id = account && account.id
            environment = kubey_environment(account: account_id)
            #TODO: handle error of apply already in progress
            environment.update(release_label: environment.release_label.gsub(/[^.]+$/,"latest")) #TODO: updating to latest release should be optional... command-line option to control it ... 
            #TODO: default should be DON'T update, but output a message about being outdated stack version if we are and name the optional command line arg to let the user also update to latest version
            environment.apply
            puts "Re-Running chef configuration scripts on #{environment.servers.size} servers on #{environment.name} (ID: #{environment.id}). Use status to command to poll for completion."
          end
        end
        mount Fix

        class Delete < KubeySubcommand
          title "delete"
          summary "Delete a cluster, shut it down first if it's running"

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account if options[:account]
            account_id = account && account.id
            environment = kubey_environment(account: account_id)
            environment.destroy!
            puts "Deleted: #{environment.name} (ID: #{environment.id})"
            #TODO: deleting an environment returns immediately but doens't complete immediately, show pending-deletion status in list somehow
          end
        end
        mount Delete

        #TODO: add/remove command 

        class DbList < KubeySubcommand
          include Ey::Core::Cli::Helpers::StreamPrinter
          title "db-list"
          summary "list RDS-backed databases"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          def handle
            account = core_account
            any_services = false
            puts "Database Services:"
            account.database_services.each_entry do |db_service|
              any_services = true
              puts [
                "#{db_service.name} (#{db_service.id})",
                db_service.db_engine_type,
                db_service.db_master_flavor.to_s + (db_service.db_master_multi_az && " (multi-az)" || ""),
                "#{db_service.db_replica_count} replicas",
              ].join(" -- ")
              # ap db_service
              # ap db_service.connected_kubey_environments
              if db_service.connected_kubey_cluster_count > 0
                db_service.connected_kubey_environments.each_entry do |env|
                  puts " Connected Cluster: #{env.name} (#{env.id})"
                end
              end
            end
            unless any_services
              "(none)"
            end
            puts
            puts "Manage (and create new) database services at: #{account.rds_management_web_uri}"
            if any_services
              puts "Create and link logical databases using 'db-create' from the CLI"
            end
          end
        end
        mount DbList

        class DbCreate < KubeySubcommand
          title "db-create"
          summary "create amazon RDS databases and link to a kubernetes cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :db_service,
            short: ['d','s'],
            long: ["db-service","database-service", "service"],
            description: 'database service name or ID',
            argument: 'DB service'

          option :name,
            short: 'n',
            long: "name",
            description: "Name for the database, a kubernetes secret will be generated with the same name.",
            argument: "database name"

          def handle
            account = core_account
            db_service = core_db_service(account_id: account.id) || raise("please specify database service (--db-service)")
            environment = kubey_environment(account: account.id) || raise("please specify a cluster (--cluster)")
            name = options[:name] || raise("Please provide a name for your database (--name)")
            req = core_client.logical_databases.create!({
              service_id:        db_service.id,
              name:              name,
              kubey_environment: environment})
            puts "Provisioning and Connecting Database: #{name} (Request ID: #{req.id})"
            puts "monitor progress by checking status on the connected cluster: #{environment.name} (#{environment.id})"
          end
        end
        mount DbCreate

        class DbDelete < KubeySubcommand
          title "db-delete"
          summary "delete RDS database and remove it's link to any kubernetes cluster"

          option :account,
            short: ['a','c'],
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          option :cluster,
            short: ["c","e"],
            long: "cluster",
            description: "cluster name or ID",
            argument: "cluster"

          option :db_service,
            short: ['d','s'],
            long: ["db-service","database-service", "service"],
            description: 'database service name or ID',
            argument: 'DB service'

          option :name,
            short: 'n',
            long: "name",
            description: "Name for the database, a kubernetes secret of the same name will be deleted.",
            argument: "database name"

            def handle
              account = core_account
              db_service = core_db_service(account_id: account.id) || raise("please specify database service (--db-service)")
              environment = core_environment(account: account.id) || raise("please specify a cluster (--cluster)")
              name = options[:name] || raise("Please provide a name for your database (--name)")
              if db_to_delete = environment.logical_databases.first(name: name)
                req = db_to_delete.destroy
                puts "De-Provisioning and Disconnecting Database: #{name} (Request ID: #{req.id})"
                puts "monitor progress by checking status on the connected cluster: #{environment.name} (#{environment.id})"
              else
                raise "Database not found: '#{name}'"
              end
            end
        end
        mount DbDelete

      end
    end
  end
end
