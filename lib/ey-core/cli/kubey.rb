require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Kubey < Subcommand
        title "kubey"
        summary "boot a kubey cluster"

        def handle
          name = "kubey_" + SecureRandom.hex(8) #TODO: make this configurable
          account_id = "a35a9477-afcb-45a2-8806-51a0dd77bfcb" #the shared account on berkeley TODO: make this configurable
          e = core_client.environments.create(account_id: account_id, name: name, kubey: true, region: "us-west-1", release_label: "crigor-kubey-0.1.0")
          ap e
          req = e.boot(:configuration => {
                        :type => :kubey,
                        :kubey_node_count => 2
          })
          ap req
          puts "BOOTING kubey environment named #{name} ... #{e.id}"
        end
      end
    end
  end
end
