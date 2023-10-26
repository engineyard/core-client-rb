require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      module EnvironmentVariables
        class Update < Ey::Core::Cli::Subcommand
            MASK = '****'.freeze
            SYMBOLS_TO_DISPLAY = 4
            MAX_LENGTH_TO_DISPLAY = 30

            include Ey::Core::Cli::Helpers::StreamPrinter

            title "update"
            summary "Update Engine Yard environment variable "

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

              puts "Update Environment Variable"
              environment = core_client.environments.first{|e| e.name == environment_name && e.application.name == application_name }
              ev =  core_client.environment_variables.first{|ev| ev.name == key && ev.environment_id == environment.id && ev.application_id == environment.application.id }
              puts ev.update(name:key,value:value)
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
