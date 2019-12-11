require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class DockerRegistryLogin < Subcommand
        title "get-docker-registry-login"
        summary "Prints the docker login command to authorize the Docker Engine with the AWS ECR registry"

        option :account,
               short:       'c',
               long:        'account',
               description: 'Name or ID of the account that the environment resides in.',
               argument:    'Account name or id'

        option :location,
               short:       'l',
               long:        'location',
               description: 'ECR availability regions',
               argument:    'Location name'

        def handle
          credentials = core_account.retrieve_docker_registry_credentials(option(:location))
          stdout.puts "docker login -u #{credentials.username} -p #{credentials.password} #{credentials.registry_endpoint}"
        end
      end
    end
  end
end
