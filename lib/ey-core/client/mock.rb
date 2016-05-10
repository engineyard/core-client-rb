class Ey::Core::Client::Mock
  include Ey::Core::Client::Shared

  include Ey::Core::Mock::Params
  include Ey::Core::Mock::Resources
  include Ey::Core::Mock::Searching
  include Ey::Core::Mock::Util
  include Ey::Core::Mock::Helper
  extend Ey::Core::Mock::Util

  def self.for(type, options={})
    case type
    when :server
      client = Ey::Core::Client::Mock.for(:user)
      server_options = options[:server] || {}

      account_name     = server_options.fetch(:account_name, SecureRandom.hex(4))
      location         = server_options.fetch(:location, "us-west-2")
      environment_name = server_options.fetch(:environment_name, SecureRandom.hex(4))

      account = client.accounts.create!(name: account_name)

      provider = account.providers.create!(type: :aws)
      environment = create_environment(account: account, name: environment_name)
      environment.servers.first
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
               cc_id     = self.uuid
               custom_id = self.uuid
               dc_id     = self.uuid
               app_id    = self.uuid
               deis_id   = self.uuid
               components = {
                 cc_id => {
                   "created_at" => Time.now.to_s,
                   "deleted_at" => nil,
                   "id"         => cc_id,
                   "name"       => "cluster_cookbooks",
                   "updated_at" => Time.now.to_s,
                   "uri"        => "git://github.com/engineyard/cluster_cookbooks.git",
                 },
                 custom_id => {
                   "created_at" => Time.now.to_s,
                   "deleted_at" => nil,
                   "id"         => custom_id,
                   "name"       => "custom_cookbooks",
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
                 "azure" => [
                   { "id" => "East US",      "name" => "East US" },
                   { "id" => "North Europe", "name" => "North Europe" },
                   { "id" => "West Europe",  "name" => "West Europe" },
                   { "id" => "West US",      "name" => "West US" },
                   { "id" => "Japan East",   "name" => "Japan East" }
                 ],
                 "aws" => [
                   { "id" => "us-east-1",      "name" => "Eastern United States" },
                   { "id" => "us-west-1",      "name" => "Western US (Northern CA)" },
                   { "id" => "us-west-2",      "name" => "Western US (Oregon)" },
                   { "id" => "sa-east-1",      "name" => "South America" },
                   { "id" => "eu-west-1",      "name" => "Europe" },
                   { "id" => "ap-southeast-1", "name" => "Singapore" },
                   { "id" => "ap-southeast-2", "name" => "Australia" },
                   { "id" => "ap-northeast-1", "name" => "Japan" }
                 ]
               }
               {
                 :account_referrals           => {},
                 :accounts                    => {},
                 :addons                      => {},
                 :addresses                   => {},
                 :agents                      => {},
                 :alerts                      => {},
                 :application_archives        => {},
                 :application_deployments     => {},
                 :applications                => {},
                 :backup_files                => {},
                 :backups                     => {},
                 :billing                     => {},
                 :blueprints                  => {},
                 :cluster_firewalls           => [],
                 :components                  => components,
                 :contact_assignments         => [],
                 :contacts                    => {},
                 :costs                       => [],
                 :database_plan_usages        => Hash.new { |h1,k1| h1[k1] = {} },
                 :database_server_firewalls   => [],
                 :database_server_revisions   => {},
                 :database_server_snapshots   => {},
                 :database_server_usages      => Hash.new { |h1,k1| h1[k1] = {} },
                 :database_servers            => {},
                 :database_services           => {},
                 :deleted                     => Hash.new {|x,y| x[y] = {}},
                 :deployments                 => {},
                 :environment_plan_usages     => Hash.new { |h1,k1| h1[k1] = {} },
                 :environments                => {},
                 :features                    => {},
                 :firewall_rules              => {},
                 :firewalls                   => {},
                 :instance_updates            => {},
                 :keypair_deployments         => {},
                 :keypairs                    => {},
                 :legacy_alerts               => {},
                 :load_balancer_nodes         => {},
                 :load_balancer_services      => {},
                 :load_balancers              => {},
                 :logical_databases           => {},
                 :logs                        => {},
                 :memberships                 => {},
                 :messages                    => {},
                 :plan_usages                 => Hash.new { |h1,k1| h1[k1] = {} },
                 :possible_provider_locations => possible_provider_locations,
                 :provider_locations          => {},
                 :providers                   => {},
                 :requests                    => {},
                 :server_events               => {},
                 :server_usages               => Hash.new { |h1,k1| h1[k1] = {} },
                 :servers                     => {},
                 :ssl_certificates            => {},
                 :storage_users               => {},
                 :storages                    => {},
                 :support_trials              => {},
                 :tasks                       => {},
                 :temp_files                  => {},
                 :tokens                      => {},
                 :untracked_servers           => {},
                 :users                       => {},
                 :volumes                     => {},
               }
             end
    end
  end

  class << self
    attr_accessor :delay
  end

  def self.reset!
    @data = nil
    @serial_id = 1
    @delay = 1
  end

  def delay
    self.class.delay
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

  def add_agent(cluster, options={})
    deis_cluster = find(:deis_clusters, cluster.identity)

    host = options[:host] || self.ip_address

    agent_id = SecureRandom.uuid
    agent = self.data[:agents][agent_id] = {
      "id"           => agent_id,
      "alerts"       => url_for("agents", agent_id, "alerts"),
      "cluster"      => url_for("deis-clusters", deis_cluster["id"]),
      "created_at"   => Time.now.to_s,
      "host"         => host,
      "last_seen_at" => options.fetch(:last_seen_at, Time.now.to_s),
      "updated_at"   => Time.now.to_s,
    }

    self.agents.new(agent)
  end
end # Mock
