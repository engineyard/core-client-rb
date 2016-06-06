require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/chef'

module Ey
  module Core
    module Cli
      module Recipes
        class Apply < Subcommand
          include Helpers::Chef

          title "apply"
          summary "Apply changes to an environment"

          option :account,
            short: "a",
            long: "account",
            description: "Name or id of account",
            argument: "account"

          switch :main,
            short: "m",
            long: "main",
            description: "Apply main recipes only"

          switch :custom,
            short: "c",
            long: "custom",
            description: "Apply custom recipes only"

          switch :quick,
            short: "q",
            long: "quick",
            description: "Quick chef run"

          switch :full,
            short: "f",
            long: "full",
            description: "Run main and custom chef"

          arg :environment

          def handle
            validate_run_type_flags
            abort_on_ambiguous_environment

            run_chef(run_type, applicable_environment)

            if switch_active?(:full)
              run_chef("custom", applicable_environment)
            end
          end

          private
          def validate_run_type_flags
            if active_run_type_flags.length > 1
              abort(
                'Only one of --main, --custom, --quick, and --full may be specified.'
              )
            end
          end

          def abort_on_ambiguous_environment
            abort "The criteria you've provided matches multiple environments. Please refine further with an account." if possible_environments.length > 1
          end

          def environment_name
            arg(:environment).first
          end

          def environments_api
            operator(options).environments
          end

          def possible_environments
            return @possible_environments if @possible_environments

            @possible_environments = [environments_api.get(environment_name)].compact

            if @possible_environments.empty?
              @possible_environments = all_pages(
                environments_api.all,
                name: environment_name
              )
            end

            @possible_environments
          end

          def applicable_environment
            possible_environments.first
          end

          def run_type
            secondary_run_types[active_run_type] || default_run_type
          end

          def active_run_type
            active_run_type_flags.first
          end

          def active_run_type_flags
            [:main, :custom, :quick, :full].select {|switch|
              switch_active?(switch)
            }
          end

          def secondary_run_types
            {
              custom: 'custom',
              quick: 'quick'
            }
          end

          def default_run_type
            'main'
          end
        end
      end
    end
  end
end
