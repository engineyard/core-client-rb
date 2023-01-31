require 'ey-core/cli/subcommand'
require 'ey-core/cli/environment_variables/list'
require 'ey-core/cli/environment_variables/create'
require 'ey-core/cli/environment_variables/update'
# require 'ey-core/cli/environment_variables/destroy'

module Ey
  module Core
    module Cli
      module EnvironmentVariables
        class Main < Ey::Core::Cli::Subcommand
          title "environment_variables"
          summary "Environment variables specific commands"

          mount Ey::Core::Cli::EnvironmentVariables::List
          mount Ey::Core::Cli::EnvironmentVariables::Create
          mount Ey::Core::Cli::EnvironmentVariables::Update
          # mount Ey::Core::Cli::EnvironmentVariables::Destroy
        end
      end
    end
  end
end
