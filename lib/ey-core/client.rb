class Ey::Core::Client < Cistern::Service
  NotPermitted = Class.new(StandardError)

  collection_path "ey-core/collections"
  model_path      "ey-core/models"
  request_path    "ey-core/requests"

  collection :account_cancellations
  collection :account_referrals
  collection :accounts
  collection :addons
  collection :addresses
  collection :alerts
  collection :application_archives
  collection :application_deployments
  collection :applications
  collection :backup_files
  collection :blueprints
  collection :components
  collection :contacts
  collection :costs
  collection :database_plan_usages
  collection :database_server_revisions
  collection :database_server_snapshots
  collection :database_server_usages
  collection :database_servers
  collection :database_services
  collection :deployments
  collection :environment_plan_usages
  collection :environments
  collection :features
  collection :firewall_rules
  collection :firewalls
  collection :gems
  collection :keypair_deployments
  collection :keypairs
  collection :legacy_alerts
  collection :load_balancer_nodes
  collection :load_balancer_services
  collection :load_balancers
  collection :logical_databases
  collection :logs
  collection :memberships
  collection :messages
  collection :plan_usages
  collection :provider_locations
  collection :providers
  collection :requests
  collection :server_events
  collection :server_usages
  collection :servers
  collection :services
  collection :ssl_certificates
  collection :storage_users
  collection :storages
  collection :tasks
  collection :tokens
  collection :untracked_addresses
  collection :untracked_servers
  collection :users
  collection :volumes

  model :account
  model :account_cancellation
  model :account_referral
  model :account_trial
  model :addon
  model :address
  model :alert
  model :application
  model :application_archive
  model :application_deployment
  model :backup_file
  model :billing
  model :blueprint
  model :component
  model :contact
  model :cost
  model :database_plan_usage
  model :database_server
  model :database_server_revision
  model :database_server_snapshot
  model :database_server_usage
  model :database_service
  model :deployment
  model :environment
  model :environment_plan_usage
  model :feature
  model :firewall
  model :firewall_rule
  model :gem
  model :keypair
  model :keypair_deployment
  model :legacy_alert
  model :load_balancer
  model :load_balancer_node
  model :load_balancer_service
  model :log
  model :logical_database
  model :membership
  model :message
  model :plan_usage
  model :provider
  model :provider_location
  model :request
  model :server
  model :server_event
  model :server_usage
  model :service
  model :ssl_certificate
  model :storage
  model :storage_user
  model :support_trial
  model :task
  model :token
  model :untracked_address
  model :untracked_server
  model :user
  model :volume

  request :acknowledge_alert
  request :apply_environment_updates
  request :apply_server_updates
  request :attach_address
  request :authorized_channel
  request :blueprint_environment
  request :boot_environment
  request :bootstrap_logical_database
  request :cancel_account
  request :change_environment_maintenance
  request :create_account
  request :create_addon
  request :create_address
  request :create_alert
  request :create_application
  request :create_application_archive
  request :create_backup_file
  request :create_database_server
  request :create_database_service
  request :create_database_service_snapshot
  request :create_environment
  request :create_firewall
  request :create_firewall_rule
  request :create_keypair
  request :create_keypair_deployment
  request :create_load_balancer
  request :create_log
  request :create_logical_database
  request :create_membership
  request :create_message
  request :create_password_reset
  request :create_provider
  request :create_server
  request :create_ssl_certificate
  request :create_storage
  request :create_storage_user
  request :create_task
  request :create_token
  request :create_untracked_address
  request :create_untracked_server
  request :create_user
  request :deploy_environment_application
  request :deprovision_environment
  request :destroy_addon
  request :destroy_blueprint
  request :destroy_database_server
  request :destroy_database_server_snapshot
  request :destroy_database_service
  request :destroy_environment
  request :destroy_firewall
  request :destroy_firewall_rule
  request :destroy_load_balancer
  request :destroy_logical_database
  request :destroy_provider
  request :destroy_server
  request :destroy_ssl_certificate
  request :destroy_storage
  request :destroy_storage_user
  request :destroy_user
  request :detach_address
  request :disable_feature
  request :discover_database_server
  request :discover_database_server_snapshots
  request :discover_provider_location
  request :download_file
  request :enable_feature
  request :get_account
  request :get_account_cancellation
  request :get_account_referrals
  request :get_account_trial
  request :get_accounts
  request :get_addon
  request :get_addons
  request :get_address
  request :get_addresses
  request :get_alert
  request :get_alerting_environments
  request :get_alerts
  request :get_api_token
  request :get_application
  request :get_application_archive
  request :get_application_archives
  request :get_application_deployment
  request :get_application_deployments
  request :get_applications
  request :get_backup_file
  request :get_backup_files
  request :get_billing
  request :get_blueprint
  request :get_blueprints
  request :get_component
  request :get_components
  request :get_contacts
  request :get_costs
  request :get_current_user
  request :get_database_plan_usages
  request :get_database_server
  request :get_database_server_revisions
  request :get_database_server_snapshot
  request :get_database_server_snapshots
  request :get_database_server_usages
  request :get_database_servers
  request :get_database_servers_firewalls
  request :get_database_service
  request :get_database_services
  request :get_deployment
  request :get_deployments
  request :get_environment
  request :get_environment_database_services
  request :get_environment_logical_databases
  request :get_environment_plan_usages
  request :get_environments
  request :get_feature
  request :get_features
  request :get_firewall
  request :get_firewall_rule
  request :get_firewall_rules
  request :get_firewalls
  request :get_gem
  request :get_keypair
  request :get_keypair_deployment
  request :get_keypair_deployments
  request :get_keypairs
  request :get_legacy_alert
  request :get_legacy_alerts
  request :get_load_balancer
  request :get_load_balancer_node
  request :get_load_balancer_nodes
  request :get_load_balancer_service
  request :get_load_balancer_services
  request :get_load_balancers
  request :get_log
  request :get_logical_database
  request :get_logical_databases
  request :get_logs
  request :get_membership
  request :get_message
  request :get_messages
  request :get_metadata
  request :get_plan_usages
  request :get_possible_provider_locations
  request :get_provider
  request :get_provider_location
  request :get_provider_locations
  request :get_providers
  request :get_request
  request :get_requests
  request :get_server
  request :get_server_event
  request :get_server_events
  request :get_server_usages
  request :get_servers
  request :get_ssl_certificate
  request :get_ssl_certificates
  request :get_storage
  request :get_storage_user
  request :get_storage_users
  request :get_storages
  request :get_support_trial
  request :get_task
  request :get_tasks
  request :get_token
  request :get_token_by_login
  request :get_tokens
  request :get_untracked_server
  request :get_untracked_servers
  request :get_user
  request :get_users
  request :get_volumes
  request :reboot_server
  request :request_callback
  request :reset_password
  request :reset_server_state
  request :restart_environment_app_servers
  request :run_cluster_application_action
  request :run_environment_application_action
  request :signup
  request :timeout_deployment
  request :unassign_environment
  request :update_addon
  request :update_address
  request :update_alert
  request :update_application_archive
  request :update_billing
  request :update_blueprint
  request :update_environment
  request :update_membership
  request :update_provider_location
  request :update_server
  request :update_ssl_certificate
  request :update_untracked_server
  request :upload_file
  request :upload_recipes_for_environment

  recognizes :token, :url, :logger, :adapter, :builder, :connection_options, :auth_id, :auth_key, :cache, :config_file

  module Shared
    attr_reader :authentication, :url, :cache

    def setup(options)
      token_dotfile = begin
                        if options[:config_file]
                          YAML.load_file(options[:config_file]) || {} # if the file is empty, yaml returns false
                        else
                          YAML.load_file(File.expand_path("~/.ey-core"))
                        end
                      rescue Errno::ENOENT
                        {}
                      end

      resolved_url = options[:url] || ENV["CORE_URL"] || "https://api.engineyard.com/"
      @url   = File.join(resolved_url, "/") # trailing slash # consistency # hash tag you're welcome
      @cache = if options[:cache] == true
                 Ey::Core::MemoryCache
               else options[:cache]
               end

      @authentication = nil
      @token = if options.has_key?(:token) && options[:token].nil?
                 @authentication = :none
               else
                 options[:token] || token_dotfile[@url] || token_dotfile[@url.gsub(/\/$/, "")] # matching with or without trailing slash
               end

      # For HMAC
      @auth_id  = options[:auth_id]
      @auth_key = options[:auth_key]

      unless @authentication == :none
        if !@auth_id && !@auth_key && !@token
          raise "Missing token. Use Ey::Core::Client.new(token: mytoken) or add \"'#{@url}': mytoken\" to your ~/.ey-core file (see: https://cloud.engineyard.com/cli)" unless @token
        elsif options[:token] || (@token && !@auth_id) # token was explicitly provided
          @authentication = :token
        else
          @authentication = :hmac
          @token = nil
        end
      end

      @logger = options[:logger] || Logger.new(nil)
    end

    # strong parameter emulation
    def require_parameters(_params, *_requirements)
      params       = Cistern::Hash.stringify_keys(_params)
      requirements = _requirements.map(&:to_s)

      requirements.each do |requirement|
        unless !params[requirement].nil?
          if self.class == Ey::Core::Client::Real
            raise ArgumentError, "param is missing or the value is empty: #{requirement}"
          else
            response(
              :status => 400,
              :body   => "param is missing or the value is empty: #{requirement}")
          end
        end
      end
      values = params.values_at(*requirements)
      values.size == 1 ? values.first : values
    end

    def require_arguments(_params, *_requirements)
      params       = Cistern::Hash.stringify_keys(_params)
      requirements = _requirements.map(&:to_s)

      values = requirements.map do |requirement|
        if params[requirement].nil?
          raise ArgumentError, "argument is missing or the value is empty: #{requirement}"
        end
        params[requirement]
      end
      [params, *values]
    end

    def require_argument(_params, *_requirements)
      params       = Cistern::Hash.stringify_keys(_params)
      requirements = _requirements.map(&:to_s)

      values = params.values_at(*requirements)
      values.all?(&:nil?) && raise(ArgumentError.new("argument is missing or the value is empty: #{requirement}"))
      values.size == 1 ? values.first : values
    end

    def require_argument!(_params, *_requirements)
      params       = Cistern::Hash.stringify_keys(_params)
      requirements = _requirements.map(&:to_s)

      values = params.values_at(*requirements)
      values.all?(&:nil?) && raise(ArgumentError.new("argument is missing or the value is empty: #{requirement}"))
      requirements.each { |r| params.delete(r) }
      values.size == 1 ? values.first : values
    end

    def url_for(*args)
      File.join(@url.to_s, *args.map(&:to_s))
    end

    # @deprecated will be removed in 3.x
    # @see {#services}
    def metadata
      services.get("core")
    end
  end
end # Ey::Core::Client

require 'ey-core/client/real'
require 'ey-core/client/mock'
