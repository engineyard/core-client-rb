require 'colorize'
require 'ey-core/cli/errors'

module Ey
  module Core
    module Cli
      module Helpers
        module Core
          module ClassMethods
            def core_file
              @core_file ||= File.expand_path("~/.ey-core")
            end

            def eyrc
              @eyrc ||= File.expand_path("~/.eyrc")
            end
          end

          def core_url
            env_url = ENV["CORE_URL"] || ENV["CLOUD_URL"]
            (env_url && File.join(env_url, '/')) || "https://api.engineyard.com/"
          end

          def longest_length_by_name(collection)
            collection.map(&:name).group_by(&:size).max.last.length
          end

          def core_yaml
            @core_yaml ||= YAML.load_file(self.class.core_file) || {}
          rescue Errno::ENOENT => e
            puts "Creating #{self.class.core_file}".yellow
            FileUtils.touch(self.class.core_file)
            retry
          end

          def operator(options)
            if options[:account]
              core_account
            elsif ENV["STAFF"]
              core_client
            else
              core_client.users.current
            end
          end

          def core_operator_and_environment_for(options={})
            unless options[:environment]
              raise "--environment is required (for a list of environments, try `ey-core environments`)"
            end
            operator = operator(options)
            environment = nil
            if options[:environment].to_i.to_s == options[:environment]
              environment = operator.environments.get(options[:environment])
            end
            unless environment
              candidate_envs = operator.environments.all(name: options[:environment])
              if candidate_envs.size > 1
                raise "Multiple matching environments found named '#{options[:environment]}', please specify --account"
              else
                environment = candidate_envs.first
              end
            end
            unless environment
              raise "environment '#{options[:environment]}' not found (for a list of environments, try `ey-core environments`)"
            end
            [operator, environment]
          end

          def core_environment_for(options={})
            core_client.environments.get(options[:environment]) || core_client.environments.first(name: options[:environment])
          end

          def core_server_for(options={})
            operator = options.fetch(:operator, core_client)
            operator.servers.get(options[:server]) || operator.servers.first(provisioned_id: options[:server])
          end

          def core_application_for(environment, options={})
            candidate_apps = nil
            unless options[:app]
              candidate_apps = environment.applications.map(&:name)
              if candidate_apps.size == 1
                options[:app] = candidate_apps.first
              else
                raise "--app is required (Candidate apps on environment #{environment.name}: #{candidate_apps.join(', ')})"
              end
            end

            app = begin
                    Integer(options[:app])
                  rescue
                    options[:app]
                  end

            if app.is_a?(Integer)
              environment.applications.get(app)
            else
              applications = environment.applications.all(name: app)
              if applications.count == 1
                applications.first
              else
                error_msg = [
                  "Found multiple applications that matched that search.",
                  "Please be more specific by specifying the account, environment, and application name.",
                  "Matching applications: #{applications.map(&:name)}.",
                ]
                if candidate_apps
                  error_msg << "applications on this environment: #{candidate_apps}"
                end
                raise Ey::Core::Cli::AmbiguousSearch.new(error_msg.join(" "))
              end
            end
          end

          def unauthenticated_core_client
            @unauthenticated_core_client ||= Ey::Core::Client.new(token: nil, url: core_url)
          end

          def core_client
            @core_client ||= begin
              opts = {url: core_url, config_file: self.class.core_file}
              opts.merge!(token: ENV["CORE_TOKEN"]) if ENV["CORE_TOKEN"]
              if ENV["DEBUG"]
                opts[:logger] = ::Logger.new(STDOUT)
              end
              Ey::Core::Client.new(opts)
            end
          rescue RuntimeError => e
            if legacy_token = e.message.match(/missing token/i) && eyrc_yaml["api_token"]
              puts "Found legacy .eyrc token.  Migrating to core file".green
              write_core_yaml(legacy_token)
              retry
            elsif e.message.match(/missing token/i)
              abort "Missing credentials: Run 'ey-core login' to retrieve your Engine Yard Cloud API token.".yellow
            else
              raise e
            end
          end

          def core_account
            @_core_account ||= begin
              if options[:account]
                found = core_client.accounts.get(options[:account]) ||
                        core_client.users.current.accounts.first(name: options[:account])
                if ENV["STAFF"]
                  found ||= core_client.accounts.first(name: options[:account])
                end
                unless found
                  account_not_found_error_message = "Couldn't find account '#{options[:account]}'"
                  if core_client.users.current.staff && !ENV["STAFF"]
                    account_not_found_error_message += " (set environment variable STAFF=1 to search all accounts)"
                  end
                  raise account_not_found_error_message
                end
                found
              else
                if core_accounts.size == 1
                  core_accounts.first
                else
                  raise "Please specify --account (options: #{core_accounts.map(&:name).join(', ')})"
                end
              end
            end
          end

          def core_accounts
            @_core_accounts ||= begin
              if ENV["STAFF"]
                core_client.accounts
              else
                core_client.users.current.accounts
              end
            end
          end

          # Fetches a list of environments by given name or ID.
          #
          # @param environment_name_or_id [String] name or ID of environment.
          #
          # @return [Array<Ey::Core::Client::Environment>] list of environments.
          def core_environments(environment_name_or_id)
            core_client.environments.all(name: environment_name_or_id).tap do |result|
              result << core_client.environments.get(environment_name_or_id) if result.empty?
            end.to_a.compact
          end

          # Fetches a list of applications by given name or ID.
          #
          # @param application_name_or_id [String] name or ID of application.
          #
          # @return [Array<Ey::Core::Client::Environment>] list of environments.
          def core_applications(application_name_or_id)
            core_client.applications.all(name: application_name_or_id).tap do |result|
              result << core_client.applications.get(application_name_or_id) if result.empty?
            end.to_a.compact
          end

          # Fetches a list of environment variables available for current user.
          #
          # @return [Array<Ey::Core::Client::EnvironmentVariable>] list of environment variables.
          def core_environment_variables
            core_client.environment_variables
          end

          def write_core_yaml(token=nil)
            core_yaml[core_url] = token if token
            File.open(self.class.core_file, "w") {|file|
              file.puts core_yaml.to_yaml
            }
          end

          def eyrc_yaml
            @eyrc_yaml ||= YAML.load_file(self.class.eyrc) || {}
          rescue Errno::ENOENT # we don't really care if this doesn't exist
            {}
          end

          def self.included(base)
            base.extend(ClassMethods)
          end
        end
      end
    end
  end
end
