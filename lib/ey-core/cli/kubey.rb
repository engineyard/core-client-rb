require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Kubey < Belafonte::App
        title "kubey"
        summary "Perform Operations on Kubernetes environments"

        class List < Subcommand
          title "list"
          summary "List Kubernetes environments"

          def handle
            puts "TODO"
          end
        end
        mount List

        class Create < Subcommand
          title "create"
          summary "Create a Kubernetes environment"

          option :account,
            short: 'c',
            long: 'account',
            description: 'Account name or ID',
            argument: 'Account'

          option :ip,
            long: 'ip',
            description: 'IP address or ID',
            argument: 'IP'

          # Berkeley:
          # DEBUG=1 CORE_URL=https://api-berkeley.engineyard.com bundle exec bin/ey-core kubey create

          # Mocked Mocked:
          # CORE_URL=http://api-development.localdev.engineyard.com:9292 bundle exec bin/ey-core kubey create

          # DEBUG=1 CORE_URL=https://api-berkeley.engineyard.com bundle exec ey-core kubey create --account staging-berkeley

          def handle
            name = "kubey_" + SecureRandom.hex(8) #TODO: make this configurable (environment name)
            region = "us-east-1" #TODO: make this configurable
            account = core_account

            # account = core_client.users.current.accounts.first #TODO: make this configurable (which account to use)
            unless account
              raise "No Accounts"
            end
            if account.providers.empty?
              raise "Account #{account.name} does not have an Amazon Account setup yet. To setup your amazon account go to: TODO"
            end

            ap account
            account_id = account.id


            e = core_client.environments.create!({
              account_id: account_id,
              name: name,
              kubey: true,
              region: region,
              # release_label: "stable-v5-3.0",
              # release_label: "crigor-kubey-0.1",
            })

            # users.current.accounts.first(name: "staging-berkeley").addresses.all(location: "us-east-1")

            ap e

            boot_configuration = {
              :type => :kubey,
              :kubey_node_count => 2,
            }

            if ip_identifier = options[:ip]
              puts "ip_identifier #{ip_identifier}"
              if found_ip = account.addresses.get(ip_identifier) ||
                            account.addresses.first(ip_address: ip_identifier)
              then
                ap found_ip
                if found_ip.server
                  ap found_ip.server
                  raise "IP already attached to a running server (TODO identify the server)"
                end
                boot_configuration[:ip_id] = found_ip.id
              else
                raise "IP not found '#{ip_identifier}'"
              end
            end

            ap boot_configuration

            req = begin
              e.boot(:configuration => boot_configuration)
            rescue Ey::Core::Response::Unprocessable => ex
              puts ex.message
              if ex.message.match(/Too many provisioned addresses/)
                existing_ips = account.addresses.all(location: region)
                puts "Try specifying an IP. e.g. --ip #{existing_ips.first.ip_address}"
              end
              raise ex
            end

            ap req
            puts "BOOTING kubey environment named #{name} ... #{e.id}"

            #TODO: how to delete/cleanup failed environment creation attempts / boot attemtps
          end
        end
        mount Create

        class Status < Subcommand
          title "status"
          summary "Get status/info about a Kubernetes environment"

          option :environment,
            short: "-e",
            long: "environment",
            description: "environment name or ID",
            argument: "environment"

          def handle
            environment = core_environment(kubey: true)
            puts "Environment #{environment.name} (#{environment.id})"
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

        class Fix < Subcommand
          title "fix"
          summary "Attempt to fix a Kubernetes environment (AKA re-run chef setup scripts on all instances in hopes it will 'do the right thing')"

          option :environment,
            short: "-e",
            long: "environment",
            description: "environment name or ID",
            argument: "environment"

          def handle
            environment = core_environment(kubey: true)
            environment.apply
            puts "Re-Running chef configuration scripts on #{environment.servers.size} servers on #{environment.name} (#{environment.id}). Use status to command to poll for completion."
          end
        end
        mount Fix

        #TODO: help command? for terminate/destroy and add/remove ? apply command for dev/support?

      end
    end
  end
end
