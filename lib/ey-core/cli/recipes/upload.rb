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

          switch :verbose,
            long: "verbose",
            description: "(used in conjunction with --apply) verbose chef run (include chef setup and stack traces)"

          switch :no_wait,
            long: "no-wait",
            description: "(used in conjunction with --apply) Don't wait for apply to finish, exit after started"

          option :watch,
            long: "watch",
            description: "Specify an instance amazon_id or server role to watch chef logs (defaults to app_master)",
            argument: "instance"

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
              opts = {}
              opts[:no_wait] = true if switch_active?(:no_wait)
              opts[:verbose] = true if switch_active?(:verbose)
              opts[:watch]   = option(:watch)
              run_chef("main", environment, opts)
            end
          end
        end
      end
    end
  end
end
