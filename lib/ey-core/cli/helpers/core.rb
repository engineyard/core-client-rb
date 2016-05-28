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

          def core_account
            @core_account ||= core_client.accounts.get(options[:account]) ||
              core_client.users.current.accounts.first(name: options[:account])
          end

          def operator(options)
            options[:account] ? core_account : core_client
          end

          def core_operator_and_environment_for(options={})
            operator = operator(options)
            environment = operator.environments.get(options[:environment]) || operator.environments.first(name: options[:environment])
            [operator, environment]
          end

          def core_environment_for(options={})
            core_client.environments.get(options[:environment]) || core_client.environments.first(name: options[:environment])
          end

          def core_server_for(options={})
            operator = options.fetch(:operator, core_client)
            operator.servers.get(options[:server]) || operator.servers.first(provisioned_id: options[:server])
          end

          def core_application_for(options={})
            return nil unless options[:app]

            app = begin
                    Integer(options[:app])
                  rescue
                    options[:app]
                  end

            actor = options[:environment].is_a?(Ey::Core::Client::Environment) ? options[:environment].account : operator(options)

            if app.is_a?(Integer)
              actor.applications.get(app)
            else
              applications = actor.applications.all(name: app)
              if applications.count == 1
                applications.first
              else
                raise Ey::Core::Cli::AmbiguousSearch.new("Found multiple applications that matched that search.  Please be more specific by specifying the account, environment, and application name.")
              end
            end
          end

          def unauthenticated_core_client
            @unauthenticated_core_client ||= Ey::Core::Client.new(token: nil, url: core_url)
          end

          def core_client
            @core_client ||= Ey::Core::Client.new(url: core_url, config_file: self.class.core_file)
          rescue RuntimeError => e
            if legacy_token = e.message.match(/missing token/i) && eyrc_yaml["api_token"]
              puts "Found legacy .eyrc token.  Migrating to core file".green
              write_core_yaml(legacy_token)
              retry
            elsif e.message.match(/missing token/i)
              abort "Missing credentials: Run 'ey login' to retrieve your Engine Yard Cloud API token.".yellow
            else
              raise e
            end
          end

          def current_accounts
            core_client.users.current.accounts
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
