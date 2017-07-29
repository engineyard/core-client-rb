module ResourceHelpers
  def load_blueprint(options={})
    application      = create_application(account: account)
    database_service = create_database_service(provider: account.providers.first)
    environment      = create_environment(account: account, application: application, database_service: database_service, environment: {name: "environment#{SecureRandom.hex(4)}"})

    [database_service, environment]
  end

  def create_application(options={})
    account = options.delete(:account) || create_account(options)
    options = Cistern::Hash.stringify_keys(options)

    options["name"]       ||= "application#{SecureRandom.hex(4)}"
    options["repository"] ||= "git://github.com/engineyard/todo.git"
    options["type"]       ||= "rails4"

    account.applications.create!(options)
  end

  def create_server(client, options={})
    options = Cistern::Hash.stringify_keys(options)

    request = environment.servers.create(
      "flavor" => "m3.medium",
      "role"   => "util",
    )

    request.resource!
  end

  def create_cost(client, options={})
    account = options[:account] || create_account(client: client)
    level = options[:level] || "summarized"
    finality = options[:finality] || "estimated"
    related_resource_type = options[:related_resource_type] || "account"
    category = options[:category] || "non-server"
    description = options[:description] || "AWS Other Services"
    value = options[:value] || "1763"
    environment = options[:environment] || nil

    client.data[:costs] << {
      billing_month:         "2015-07",
      data_type:             "cost",
      level:                 level,
      finality:              finality,
      related_resource_type: related_resource_type,
      category:              category,
      units:                 "USD cents",
      description:           description,
      value:                 value,
      account:               client.url_for("accounts/#{account.identity}"),
      environment:           environment
    }
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

    unless account.providers.first || options[:provider]
      create_provider(account: account)
    end

    environment             = options[:environment] || {}
    application             = options[:application] || create_application(account: account)
    database_service        = options[:database_service]
    configuration           = Cistern::Hash.stringify_keys(options[:configuration] || {})
    configuration["type"] = "production-cluster" if configuration["type"] == "production"
    configuration["type"] ||= "solo"
    environment[:name]    ||= options.fetch(:name, SecureRandom.hex(3))
    environment[:region]  ||= "us-west-2"

    environment.merge!(application_id: application.id, account: account)
    environment.merge!(database_service: database_service) if database_service
    environment = client.environments.create!(environment)

    unless options[:boot] == false
      request = environment.boot(configuration: configuration, application_id: application.id)
      request.ready!
    end
    environment
  end

  def create_environment_variable(options={})
    application = options[:application] || create_application
    environment = options[:environment] || create_environment

    environment_variable = options[:environment_variable] || {}
    environment_variable.merge!(application_id: application.id, environment: environment.id)
    environment_variable[:name] ||= SecureRandom.hex(8)
    environment_variable[:value] ||= SecureRandom.hex(32)

    client.environment_variables.create!(environment_variable)
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

    attributes.fetch("type")

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

    database_service.databases.create!(
      :name     => SecureRandom.hex(6),
      :username => "ey#{SecureRandom.hex(6)}",
      :password => SecureRandom.hex(8),
    ).resource!
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

World(ResourceHelpers)
