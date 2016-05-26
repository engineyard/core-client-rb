module Ey
  module Core
    module Cli
      module Helpers
        class ServerSieve
          ROLES = [
            :app_servers,
            :db_servers,
            :db_master,
            :utilities
          ]

          attr_reader :servers_api, :options

          def self.filter(servers_api, options = {})
            new(servers_api, options).filtered
          end

          def initialize(servers_api, options = {})
            @servers_api = servers_api
            @options = options
          end

          def filtered
            return all_servers if requested?(:all)

            requested_roles.map {|role|
              role == :utilities ? utils_named(option(:utilities)) : send(role)
            }.flatten.uniq
          end

          private
          def requested_roles
            #self.class::
            ROLES.select {|role| requested?(role)}
          end

          def option(name)
            options[name]
          end

          def requested?(name)
            option(name)
          end

          def all_servers
            servers_api.all.to_a.uniq
          end

          def app_servers
            ['app_master', 'app', 'solo'].
              map {|role| servers_api.all(role: role).to_a}.
              flatten
          end

          def db_servers
            db_master + servers_api.all(role: 'db_slave').to_a
          end

          def db_master
            ['db_master', 'solo'].
              map {|role| servers_api.all(role: role).to_a}.
              flatten
          end

          def utils_named(name)
            filter = {role: 'util'}
            filter[:name] = name unless name.downcase == 'all'

            servers_api.all(filter).to_a
          end
        end
      end
    end
  end
end
