require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      module EnvironmentVariables
        class List < Ey::Core::Cli::Subcommand
            MASK = '****'.freeze
            SYMBOLS_TO_DISPLAY = 4
            MAX_LENGTH_TO_DISPLAY = 30

            include Ey::Core::Cli::Helpers::StreamPrinter

            title "list"
            summary "Retrieve a list of Engine Yard environment variables for environments that you have access to."

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

            switch :display_sensitive,
            short: 's',
            long: 'display_sensitive',
            description: 'Determines whether values of sensitive variables should be printed',
            argument: 'Display Sensitive'
            
            def handle
            environment_variables = if option(:application)
                                        core_applications(option(:application)).flat_map(&:environment_variables)
                                    elsif option(:environment)
                                        core_environments(option(:environment)).flat_map(&:environment_variables)
                                    else
                                        core_environment_variables
                                    end
              stream_print("ID" => 10, "Name" => 30, "Value" => 50, "Environment" => 30, "Application" => 30) do |printer|
                environment_variables.each_entry do |ev|
                  printer.print(ev.id, ev.name, ev.value, ev.environment_name, ev.application_name)
                end
              end
            end

            private

            def print_variable_value(environment_variable)
              puts "in print_variable_value"
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
