module ResourceHelper
  def load_blueprint(options={})
    logical_database = create_logical_database(client: options[:client], provider: account.providers.first)

    application = account.applications.create!(name: "application#{SecureRandom.hex(4)}", repository: "git://github.com/engineyard/todo.git", type: "rails3")
    environment = account.environments.create!(name: "environment#{SecureRandom.hex(4)}")
    www_cluster = environment.clusters.create!(provider: provider, location: "us-west-2", name: "app#{SecureRandom.hex(4)}", release_label: "ubuntu-1.0")
    app_component =  client.components.first(name: "default_deployer")
    www_cluster_component = www_cluster.cluster_components.create!(component: app_component, configuration: { application: application.id})

    logical_database.connect(www_cluster_component)

    [logical_database.service, environment]
  end

  def create_server(client, options={})
    options = Cistern::Hash.stringify_keys(options)

    if provider = options.delete("provider")
      options["provider"] = client.url_for("/providers/#{provider.id}")
    end

    if environment = options.delete("environment")
      options["environment"] = client.url_for("/environments/#{environment.id}")
    end

    server_id      = options["id"] ||= client.serial_id
    provisioned_id = options["provisioned_id"] ||= client.uuid[0..6]

    client.servers.new(
      client.data[:servers][server_id] = {
        "events"           => client.url_for("/servers/#{server_id}/events"),
        "private_hostname" => "#{provisioned_id}.private.example.org",
        "provider"         => provider,
        "public_hostname"  => "#{provisioned_id}.public.example.org",
        "ssh_port"         => 22,
        "state"            => "running",
        "token"            => SecureRandom.hex(16),
      }.merge(options)
    )
  end

  def create_account_referral(client, options={})
    referred = options.delete(:referred) || create_account(client: client)
    referrer = options.delete(:referrer) || create_account(client: client)

    account_referral_id = SecureRandom.uuid
    referral = client.data[:account_referrals][account_referral_id] = {
      "id" => account_referral_id,
      "referrer" => client.url_for("accounts/#{referrer.identity}"),
      "referred" => client.url_for("accounts/#{referred.identity}"),
    }

    client.account_referrals.new(referral)
  end

  def create_firewall(client, options={})
    provider = options.fetch(:provider) { create_provider(client: client) }

    firewall_params = options[:firewall] || {}
    name     = firewall_params.delete(:name) || SecureRandom.hex(6)
    location = firewall_params.delete(:location) || "us-west-2"

    client.firewalls.create!(
      :name     => name,
      :location => location,
      :provider => provider,
    ).resource!
  end

  def create_cluster(options={})
    client = (defined?(client) && client) || options.fetch(:client)

    environment = options[:environment] || create_environment(options)
    provider    = options[:provider] || create_provider(options.merge(account: environment.account))

    cluster_params = options[:cluster] || {}
    name     = cluster_params.delete(:name) || SecureRandom.hex(6)
    location = cluster_params.delete(:location) || "us-west-2"

    client.clusters.create!(
      :name        => name,
      :location    => location,
      :environment => environment,
      :provider    => provider,
    )
  end

  def create_cluster_update(options={})
    client = (defined?(client) && client) || options.fetch(:client)
    cluster = options[:cluster] || create_cluster(options)

    cluster.slots.create({ quantity: 2, flavor: "m3.large" }.merge(options[:slot] || {}))

    cluster.cluster_updates.create!.resource!
  end

  def create_database_service(options={})
    provider = options[:provider] || create_provider(options.merge(client: client))

    database_service_params = Hashie::Mash.new(
      :name     => Faker::Name.first_name,
      :provider => provider,
    ).merge(options.fetch(:database_service, {}))

    database_server_params = Hashie::Mash.new(
        :location => "us-west-2c",
        :flavor   => "db.m3.large",
        :engine   => "postgres",
        :version  => "9.3.5",
    ).merge(options.fetch(:database_server, {}))

    client.database_services.create!(database_service_params.merge(database_server: database_server_params)).resource!
  end

  def create_environment(options={})
    account = options[:account] || create_account(options)

    environment = options[:environment] || {}
    environment[:name] ||= SecureRandom.hex(3)

    account.environments.create!(environment)
  end

  def create_provider_location(client, attributes={})
    attributes = Cistern::Hash.stringify_keys(attributes)

    if provider = attributes.delete("provider")
      attributes["provider"] = client.url_for("/providers/#{provider.id}")
    end

    attributes["id"] ||= client.uuid
    client.data[:provider_locations][attributes["id"]] = attributes

    client.provider_locations.new(attributes)
  end

  def create_server_event(client, attributes={})
    attributes = Cistern::Hash.stringify_keys(attributes)

    raise "type needed" unless attributes["type"]

    if server = attributes.delete("server")
      attributes["server"] = client.url_for("/servers/#{server.id}")
    end

    event_id = attributes["id"] ||= SecureRandom.uuid

    client.server_events.new(
      client.data[:server_events][event_id] = attributes
    )
  end

  def create_logical_database(options={})
    database_service = options.fetch(:database_service) { create_database_service(options) }

    database_service.databases.create!({
      :name     => SecureRandom.hex(6),
      :username => "ey#{SecureRandom.hex(6)}",
      :password => SecureRandom.hex(8),
    }).resource!
  end

  def create_untracked_server(options={})
    provider = options.fetch(:provider) { create_provider(options) }

    untracked_server = options[:untracked_server] || {}

    provisioner_id = untracked_server[:provisioner_id] || SecureRandom.uuid
    location       = untracked_server[:location]       || "us-west-2b"
    provisioned_id = untracked_server[:provisioned_id] || "i-#{SecureRandom.hex(4)}"
    state          = untracked_server[:state]          || "found"

    client.untracked_servers.create(
      :location       => location,
      :provider       => provider,
      :provisioned_id => provisioned_id,
      :provisioner_id => provisioner_id,
      :state          => state,
    )
  end
end

RSpec.configure do |config|
  config.include(ResourceHelper)
end
