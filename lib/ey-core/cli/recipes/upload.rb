require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/chef'
require 'ey-core/cli/helpers/archive'

module Ey
  module Core
    module Cli
      module Recipes
        class Upload < Ey::Core::Cli::Subcommand
          include Ey::Core::Cli::Helpers::Archive
          include Ey::Core::Cli::Helpers::Chef

          title "upload"
          summary "Upload custom recipes to an environment"

          option :environment,
            short: "e",
            long: "environment",
            description: "Environment that will receive the recipes.",
            argument: "environment"

          option :account,
            short: "c",
            long: "account",
            description: "Name of the account in which the environment can be found.",
            argument: "account"

          option :file,
            short: "f",
            long: "file",
            description: "Path to recipes",
            argument: "path"

          switch :apply,
            short: "a",
            long: "apply",
            description: "Apply the recipes immediately after they are uploaded"

          def handle
            operator, environment = core_operator_and_environment_for(options)
            path = option(:file) || "cookbooks/"

            puts "Uploading custom recipes for #{environment.name}".green

            begin
              upload_recipes(environment, path)
              puts "Uploading custom recipes complete".green
            rescue => e
              puts e.message
              abort "There was a problem uploading the recipes".red
            end

            if switch_active?(:apply)
              run_chef("main", environment)
            end
          end
        end
      end
    end
  end
end
