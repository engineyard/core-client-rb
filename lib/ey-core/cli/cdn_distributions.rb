require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/stream_printer'

module Ey
  module Core
    module Cli
      class CdnDistributions < Subcommand

        include Ey::Core::Cli::Helpers::StreamPrinter

        title "cdn_distributions"
        summary "Retrieve information about cdn distributions you have configured for your environments or applications."

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
          cdn_distributions = if option(:application)
                                core_applications(option(:application)).flat_map(&:cdn_distributions)
                              elsif option(:environment)
                                core_environments(option(:environment)).flat_map(&:cdn_distributions)
                              else
                                core_cdn_distributions
                              end

          stream_print("ID" => 10, "Domain" => 30, "Origin" => 50, "Aliases" => 50, "Enabled" => 5, "Environment" => 30, "Application" => 30) do |printer|
            cdn_distributions.each_entry do |distribution|
              printer.print(distribution.id, distribution.domain, distribution.aliases.join(', '), distribution.enabled ? "yes" : "no", distribution.environment.name, distribution.application.name)
            end
          end
        end
      end
    end
  end
end