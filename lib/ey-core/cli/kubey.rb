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

          # Berkeley:
          # DEBUG=1 CORE_URL=https://api-berkeley.engineyard.com bundle exec bin/ey-core kubey create

          # Mocked Mocked:
          # CORE_URL=http://api-development.localdev.engineyard.com:9292 bundle exec bin/ey-core kubey create

          def handle
            name = "kubey_" + SecureRandom.hex(8) #TODO: make this configurable (environment name)
            account = core_client.users.current.accounts.first #TODO: make this configurable (which account to use)
            account_id = account.id
            e = core_client.environments.create!(
              account_id: account_id,
              name: name,
              kubey: true,
              # region: "us-west-1",
              region: "us-east-1",
              # release_label: "stable-v5-3.0",
              # release_label: "crigor-kubey-0.1",
            )
            #TODO :how do we display validation errors if e.false
            ap e
            req = e.boot(:configuration => {
                          :type => :kubey,
                          :kubey_node_count => 2
            })
            ap req
            puts "BOOTING kubey environment named #{name} ... #{e.id}"
          end
        end
        mount Create

        class Info < Subcommand
          title "info"
          summary "Get info about a Kubernetes environment"

          def handle
            puts "TODO"
          end
        end
        mount Info

        #TODO: help command? for terminate/destroy and add/remove ? apply command for dev/support?

      end
    end
  end
end
