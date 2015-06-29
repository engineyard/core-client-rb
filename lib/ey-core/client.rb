class Ey::Core::Client < Cistern::Service
  collection_path "ey-core/collections"
  model_path "ey-core/models"
  request_path "ey-core/requests"

  collection :accounts
  collection :account_cancellations
  collection :addons
  collection :addon_attachments
  collection :addresses
  collection :alerts
  collection :applications
  collection :application_archives
  collection :application_deployments
  collection :backup_files
  collection :backups
  collection :cluster_components
  collection :cluster_updates
  collection :clusters
  collection :component_actions
  collection :components
  collection :connectors
  collection :database_server_revisions
  collection :database_server_snapshots
  collection :database_servers
  collection :database_services
  collection :database_server_usages
  collection :database_plan_usages
  collection :environments
  collection :environment_plan_usages
  collection :firewalls
  collection :firewall_rules
  collection :features
  collection :keypairs
  collection :keypair_deployments
  collection :legacy_alerts
  collection :load_balancers
  collection :load_balancer_services
  collection :load_balancer_nodes
  collection :logical_databases
  collection :logs
  collection :memberships
  collection :messages
  collection :contacts
  collection :plan_usages
  collection :providers
  collection :provider_locations
  collection :requests
  collection :servers
  collection :server_events
  collection :server_usages
  collection :slots
  collection :slot_components
  collection :ssl_certificates
  collection :storage_users
  collection :storages
  collection :tasks
  collection :tokens
  collection :untracked_servers
  collection :users
  collection :volumes

  model :account
  model :account_trial
  model :alert
  model :billing
  model :account_cancellation
  model :addon
  model :addon_attachment
  model :address
  model :legacy_alert
  model :application
  model :application_archive
  model :application_deployment
  model :backup
  model :backup_file
  model :cluster
  model :cluster_component
  model :cluster_update
  model :component
  model :component_action
  model :connector
  model :database_server
  model :database_server_snapshot
  model :database_server_revision
  model :database_service
  model :database_server_usage
  model :database_plan_usage
  model :environment
  model :environment_plan_usage
  model :feature
  model :firewall
  model :firewall_rule
  model :keypair
  model :keypair_deployment
  model :load_balancer
  model :load_balancer_service
  model :load_balancer_node
  model :log
  model :logical_database
  model :membership
  model :message
  model :metadata
  model :contact
  model :plan_usage
  model :provider
  model :provider_location
  model :request
  model :server
  model :server_event
  model :server_usage
  model :slot
  model :slot_component
  model :ssl_certificate
  model :storage
  model :storage_user
  model :task
  model :token
  model :untracked_server
  model :user
  model :volume

  request :attach_address
  request :authorized_channel
  request :bootstrap_logical_database
  request :cancel_account
  request :create_account
  request :create_addon
  request :create_address
  request :create_alert
  request :create_application
  request :create_application_archive
  request :create_backup
  request :create_backup_file
  request :create_cluster
  request :create_cluster_component
  request :create_cluster_update
  request :create_connector
  request :create_database_server
  request :create_database_service
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
  request :create_provider
  request :create_slots
  request :create_ssl_certificate
  request :create_storage
  request :create_storage_user
  request :create_task
  request :create_token
  request :create_untracked_server
  request :create_user
  request :detach_address
  request :destroy_addon
  request :destroy_cluster
  request :destroy_environment
  request :destroy_database_service
  request :destroy_database_server
  request :destroy_firewall
  request :destroy_user
  request :destroy_firewall_rule
  request :destroy_load_balancer
  request :destroy_logical_database
  request :destroy_provider
  request :destroy_server
  request :destroy_ssl_certificate
  request :destroy_storage
  request :destroy_storage_user
  request :disable_feature
  request :discover_database_server
  request :discover_database_server_snapshots
  request :discover_provider_location
  request :download_file
  request :enable_feature
  request :finish_backup
  request :get_account
  request :get_account_cancellation
  request :get_account_trial
  request :get_accounts
  request :get_addon
  request :get_addon_attachment
  request :get_addon_attachments
  request :get_addons
  request :get_address
  request :get_addresses
  request :get_alert
  request :get_alerting_environments
  request :get_alerts
  request :get_application
  request :get_application_archive
  request :get_application_archives
  request :get_application_deployment
  request :get_application_deployments
  request :get_applications
  request :get_backup
  request :get_backup_file
  request :get_backup_files
  request :get_backups
  request :get_billing
  request :get_cluster
  request :get_cluster_component
  request :get_cluster_components
  request :get_cluster_update
  request :get_cluster_updates
  request :get_clusters
  request :get_component
  request :get_component_action
  request :get_component_actions
  request :get_components
  request :get_connector
  request :get_connectors
  request :get_contacts
  request :get_current_user
  request :get_database_server
  request :get_database_server_revisions
  request :get_database_server_snapshot
  request :get_legacy_alert
  request :get_legacy_alerts
  request :get_database_server_snapshots
  request :get_database_servers
  request :get_database_servers_firewalls
  request :get_database_service
  request :get_database_services
  request :get_database_server_usages
  request :get_database_plan_usages
  request :get_environment
  request :get_environment_database_services
  request :get_environment_logical_databases
  request :get_environment_plan_usages
  request :get_environments
  request :get_feature
  request :get_features
  request :get_firewall
  request :get_firewalls
  request :get_firewall_rule
  request :get_firewall_rules
  request :get_keypair
  request :get_keypairs
  request :get_keypair_deployment
  request :get_keypair_deployments
  request :get_load_balancer
  request :get_load_balancers
  request :get_load_balancer_service
  request :get_load_balancer_services
  request :get_load_balancer_node
  request :get_load_balancer_nodes
  request :get_log
  request :get_logical_database
  request :get_logs
  request :get_logical_databases
  request :get_membership
  request :get_message
  request :get_messages
  request :get_metadata
  request :get_plan_usages
  request :get_possible_provider_locations
  request :get_provider
  request :get_providers
  request :get_provider_location
  request :get_provider_locations
  request :get_request
  request :get_requests
  request :get_server
  request :get_server_usages
  request :get_servers
  request :get_server_event
  request :get_server_events
  request :get_slot
  request :get_slot_component
  request :get_slot_components
  request :get_slots
  request :get_ssl_certificate
  request :get_ssl_certificates
  request :get_storage
  request :get_storages
  request :get_storage_user
  request :get_storage_users
  request :get_task
  request :get_tasks
  request :get_untracked_server
  request :get_untracked_servers
  request :get_user
  request :get_users
  request :get_volumes
  request :request_callback
  request :run_cluster_application_action
  request :reboot_server
  request :run_cluster_component_action
  request :run_environment_application_action
  request :signup
  request :update_addon
  request :update_addon_attachment
  request :update_alert
  request :update_application_archive
  request :update_billing
  request :update_cluster
  request :update_cluster_component
  request :update_connector
  request :update_membership
  request :update_server
  request :update_slot
  request :update_slot_component
  request :update_ssl_certificate
  request :update_untracked_server
  request :upload_file

  recognizes :token, :url, :logger, :adapter, :builder, :connection_options, :auth_id, :auth_key, :cache

  module Shared
    attr_reader :authentication, :url, :cache

    def setup(options)
      token_dotfile = begin
                        YAML.load_file(File.expand_path("~/.ey-core"))
                      rescue Errno::ENOENT
                        {}
                      end

      resolved_url = options[:url] || ENV["CORE_URL"] || "https://api.engineyard.com/"
      @url   = File.join(resolved_url, "/") # trailing slash # consistency # hash tag you're welcome
      @cache = if options[:cache] == true
                 Ey::Core::MemoryCache
               else options[:cache]
               end
      @token = options[:token] || token_dotfile[@url] || token_dotfile[@url.gsub(/\/$/, "")] # matching with or without trailing slash

      # For HMAC
      @auth_id  = options[:auth_id]
      @auth_key = options[:auth_key]

      if !@auth_id && !@auth_key && !@token
        raise "Missing token. Use Ey::Core::Client.new(token: mytoken) or add \"'#{@url}': mytoken\" to your ~/.ey-core file" unless @token
      elsif options[:token] || (@token && !@auth_id) # token was explicitly provided
        @authentication = :token
      else
        @authentication = :hmac
        @token = nil
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

    def url_for(path)
      File.join(@url.to_s, path.to_s)
    end
  end

  class Real
    include Shared

    def initialize(options={})
      setup(options)
      adapter            = options[:adapter] || Faraday.default_adapter
      connection_options = options[:connection_options] || {}

      @connection = Faraday.new({url: @url}.merge(connection_options)) do |builder|
        # response
        builder.response :json, content_type: /json/

        builder.use Ey::Core::ResponseCache, cache: @cache if @cache

        # request
        builder.request :multipart
        builder.request :json

        # request
        builder.request :retry,
          :max                 => 5,
          :interval            => 1,
          :interval_randomness => 0.05,
          :backoff_factor      => 2

        if @token
          builder.use Ey::Core::TokenAuthentication, @token
        else
          builder.use :hmac, @auth_id, @auth_key
        end

        builder.use Ey::Core::Logger, @logger

        if options[:builder]
          options[:builder].call(builder)
        end

        builder.adapter(*adapter)
      end
    end

    def request(options={})
      method  = options[:method] || :get
      url     = options[:url] || File.join(@url, options[:path] || "/")
      #@todo query is a band-aid
      query   = options[:query] || {}
      params  = query.merge(options[:params] || {})
      body    = options[:body]
      headers = options[:headers] || {}

      default_content_type = if !body && !params.empty?
                               "application/x-www-form-urlencoded"
                             else
                               "application/json"
                             end
      headers = {
        "Content-Type" => default_content_type,
        "Accept"       => accept_type,
      }.merge(headers)

      response = @connection.send(method) do |req|
        req.url(url)
        req.headers.merge!(headers)
        req.params.merge!(params)
        req.body = body
      end

      Ey::Core::Response.new(
        :status  => response.status,
        :headers => response.headers,
        :body    => response.body,
        :request => {
          :method  => method,
          :url     => url,
          :headers => headers,
          :body    => body,
          :params  => params,
        }
      ).raise!
    end

    def accept_type
      "application/vnd.engineyard.v2+json"
    end

    def reset!
      request(method: :post, path: "/client/reset")
    rescue Ey::Core::Response::NotFound # allow me to test against something real where this route doesn't exist
      nil
    end

  end # Real

  class Mock
    include Shared

    include Ey::Core::Mock::Params
    include Ey::Core::Mock::Resources
    include Ey::Core::Mock::Searching
    include Ey::Core::Mock::Util
    include Ey::Core::Mock::Helper
    extend Ey::Core::Mock::Util

    def self.share_ey_sso_backend!
      @share_ey_sso_backend = true
    end

    def self.share_ey_sso_backend?
      @share_ey_sso_backend
    end

    def share_ey_sso_backend?
      self.class.share_ey_sso_backend?
    end

    def self.for(type, options={})
      case type
      when :server
        client = Ey::Core::Client::Mock.for(:user)
        server_options = options[:server] || {}

        account_name     = server_options.fetch(:account_name, SecureRandom.hex(4))
        location         = server_options.fetch(:location, "us-west-2")
        cluster_name     = server_options.fetch(:cluster_name, SecureRandom.hex(4))
        environment_name = server_options.fetch(:environment_name, SecureRandom.hex(4))

        account = client.accounts.create!(name: account_name)

        provider = account.providers.create!(type: :aws)
        environment = account.environments.create!(name: environment_name)
        cluster = client.clusters.create!(environment: environment, location: location, provider: provider, name: cluster_name)
        cluster.slots.create!
        cluster.cluster_updates.create!.resource!
        cluster.slots.first.server
      when :user
        user = Ey::Core::Client::Mock.for(:consumer).users.create!(
          {
          :name  => "#{SecureRandom.hex(3)} #{SecureRandom.hex(3)}",
          :email => "#{SecureRandom.hex(8)}@example.org",
          }.merge(options[:user] || {})
        )
        Ey::Core::Client.new(token: user.token)
      when :consumer
        Ey::Core::Client.new({auth_id: SecureRandom.hex(8), auth_key: SecureRandom.hex(16)}.merge(options[:consumer] || {}))
      end
    end

    def self.data
      @data ||= Hash.new do |h,k|
        h[k] = begin
                  cc_id  = self.uuid
                  dc_id  = self.uuid
                  app_id = self.uuid
                  deis_id = self.uuid
                  components = {
                    cc_id => {
                      "created_at" => Time.now.to_s,
                      "deleted_at" => nil,
                      "id"         => cc_id,
                      "name"       => "cluster_cookbooks",
                      "updated_at" => Time.now.to_s,
                      "uri"        => "git://github.com/engineyard/cluster_cookbooks.git",
                    },
                    dc_id => {
                      "created_at" => Time.now.to_s,
                      "deleted_at" => nil,
                      "id"         => dc_id,
                      "name"       => "default_cookbooks",
                      "updated_at" => Time.now.to_s,
                      "uri"        => "git://github.com/engineyard/cloud_cookbooks.git",
                    },
                    app_id => {
                      "created_at" => Time.now.to_s,
                      "deleted_at" => nil,
                      "id"         => app_id,
                      "name"       => "default_deployer",
                      "updated_at" => Time.now.to_s,
                      "uri"        => "git://github.com/engineyard/engineyard-serverside.git",
                    },
                    deis_id => {
                      "created_at" => Time.now.to_s,
                      "deleted_at" => nil,
                      "id"         => deis_id,
                      "name"       => "deis",
                      "updated_at" => Time.now.to_s,
                      "uri"        => "git://github.com/deis/deis.git",
                    }
                  }
                  possible_provider_locations = {
                    "azure" => [{"id"=>"East US", "name"=>"East US"}, {"id"=>"North Europe", "name"=>"North Europe"}, {"id"=>"West Europe", "name"=>"West Europe"}, {"id"=>"West US", "name"=>"West US"}, {"id"=>"Japan East", "name"=>"Japan East"}],
                    "aws" => [{"id"=>"us-east-1", "name"=>"Eastern United States"}, {"id"=>"us-west-1", "name"=>"Western US (Northern CA)"}, {"id"=>"us-west-2", "name"=>"Western US (Oregon)"}, {"id"=>"sa-east-1", "name"=>"South America"}, {"id"=>"eu-west-1", "name"=>"Europe"}, {"id"=>"ap-southeast-1", "name"=>"Singapore"}, {"id"=>"ap-southeast-2", "name"=>"Australia"}, {"id"=>"ap-northeast-1", "name"=>"Japan"}]
                  }
                  {
                    :accounts                    => {},
                    :addons                      => {},
                    :addresses                   => {},
                    :alerts                      => {},
                    :applications                => {},
                    :application_archives        => {},
                    :application_deployments     => {},
                    :backup_files                => {},
                    :backups                     => {},
                    :billing                     => {},
                    :cluster_components          => {},
                    :cluster_updates             => {},
                    :clusters                    => {},
                    :cluster_firewalls           => [],
                    :component_actions           => {},
                    :components                  => components,
                    :connectors                  => {},
                    :contacts                    => {},
                    :contact_assignments         => [],
                    :database_server_firewalls   => [],
                    :database_server_revisions   => {},
                    :database_server_snapshots   => {},
                    :database_servers            => {},
                    :database_services           => {},
                    :database_server_usages      => Hash.new { |h1,k1| h1[k1] = {} },
                    :database_plan_usages        => Hash.new { |h1,k1| h1[k1] = {} },
                    :environment_plan_usages     => Hash.new { |h1,k1| h1[k1] = {} },
                    :deleted                     => Hash.new {|x,y| x[y] = {}},
                    :environments                => {},
                    :features                    => {},
                    :firewalls                   => {},
                    :firewall_rules              => {},
                    :keypairs                    => {},
                    :keypair_deployments         => {},
                    :legacy_alerts               => {},
                    :load_balancers              => {},
                    :load_balancer_services      => {},
                    :load_balancer_nodes         => {},
                    :logs                        => {},
                    :logical_databases           => {},
                    :memberships                 => {},
                    :messages                    => {},
                    :plan_usages                 => Hash.new { |h1,k1| h1[k1] = {} },
                    :possible_provider_locations => possible_provider_locations,
                    :projects                    => {},
                    :providers                   => {},
                    :provider_locations          => {},
                    :requests                    => {},
                    :servers                     => {},
                    :server_events               => {},
                    :server_usages               => Hash.new { |h1,k1| h1[k1] = {} },
                    :slots                       => {},
                    :slot_components             => {},
                    :ssl_certificates            => {},
                    :storages                    => {},
                    :storage_users               => {},
                    :tasks                       => {},
                    :temp_files                  => {},
                    :untracked_servers           => {},
                    :users                       => {},
                    :volumes                     => {},
                    }
                end
      end
    end

    def self.reset!
      @data = nil
      @serial_id = 1
    end

    def data
      self.class.data[self.url]
    end

    attr_reader :current_server

    def initialize(options={})
      setup(options)
      @url = options[:url] || "https://api.engineyard.com"

      if authentication == :token
        if server = self.data[:servers].values.find { |s| s["token"] == options[:token] }
          @current_server = server
        else
          @current_user ||= begin
                              _,found = self.data[:users].detect{|k,v| v["token"] == options[:token]}
                              found
                            end

          # FIXME(rs) get rid of this and the implicit Josh Lane creation entirely
          @current_user ||= begin
                              _,found = self.data[:users].detect{|k,v| v["email"] == "jlane@engineyard.com"}
                              found
                            end

          unless @current_user
            user = Ey::Core::Client.new({
              :url      => @url,
              :auth_id  => SecureRandom.hex(8),
              :auth_key => SecureRandom.hex(16),
            }).users.create!({
              :email => "jlane@engineyard.com",
              :name  => "Joshua Lane",
            })

            if options[:token]
              self.data[:users][user.id]["token"] = options[:token]
            end

            @current_user = self.data[:users][user.id]
          end
        end
      end
    end

    # Lazily re-seeds data after reset
    # @return [Hash] current user response
    def current_user
      if @current_user
        self.data[:users][@current_user["id"]] ||= @current_user

        @current_user
      end
    end

    def response(options={})
      status  = options[:status] || 200
      body    = options[:body]
      headers = {
        "Content-Type"  => "application/json; charset=utf-8"
      }.merge(options[:headers] || {})


      @logger.debug "MOCKED RESPONSE: #{status}"
      @logger.debug('response') { headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n") }
      @logger.debug caller[0]
      @logger.debug('response.body') { body }
      @logger.debug ''

      Ey::Core::Response.new(
        :status  => status,
        :headers => headers,
        :body    => body,
        :request => {
          :method  => :mocked,
          :url     => caller[1],
        }
      ).raise!
    end

    def serial_id
      @@serial_id ||= 0
      @@serial_id += 1
    end
  end # Mock
end # Ey::Core::Client

