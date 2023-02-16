require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      module EnvironmentVariables
        class Create < Ey::Core::Cli::Subcommand
            MASK = '****'.freeze
            SYMBOLS_TO_DISPLAY = 4
            MAX_LENGTH_TO_DISPLAY = 30

            include Ey::Core::Cli::Helpers::StreamPrinter

            title "create"
            summary "Create Engine Yard environment variable "

            option :environment,
            short: 'e',
            long: 'environment',
            description: 'Filter by environmeent name or id',
            argument: 'Environment'

            option :application,
            short: 'a',
            long: 'application',
            description: 'Filter by application name or id',
            argument: 'Application'

            option :display_sensitive,
            short: 's',
            long: 'display_sensitive',
            description: 'Determines whether values of sensitive variables should be printed',
            argument: 'Display Sensitive'
            
            
            option :key,
            short: 'k',
            long: 'key',
            description: 'Key',
            argument: 'Key'

            option :value,
            short: 'v',
            long: 'value',
            description: 'Value',
            argument: 'Value'

            def handle
              application_name = option(:application)
              environment_name = option(:environment)
              key = option(:key)
              value = option(:value)

              puts "Create Environment Variable"
              env = core_client.environments.filter{ |env| env.name == environment_name }&.first
              app = core_client.applications.filter{ |app| app.name == application_name }&.first
              puts core_client.environment_variables.create(name:key,value:value,environment_id:env.id, application_id: app.id)
            end

            private

            def print_variable_value(environment_variable)
              if environment_variable.sensitive && !switch_active?(:display_sensitive)
                  hide_sensitive_data(environment_variable.value)
              else
                  environment_variable.value
              end
            end

            def hide_sensitive_data(value)
            if value.length > SYMBOLS_TO_DISPLAY
                MASK + value[-SYMBOLS_TO_DISPLAY, SYMBOLS_TO_DISPLAY]
            else
                MASK
            end
            end
        end
      end
    end
  end
end
