require 'spec_helper'

describe "database services" do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it 'should create a database service with contacts and service level' do
    name     = Faker::Name.first_name
    location = "us-west-2c"
    service_level = "level-2"
    contact_info = {
      :name         => Faker::Name.name,
      :email        => Faker::Internet.email,
      :title        => Faker::Name.title,
      :phone_number => Faker::PhoneNumber.phone_number,
    }

    database_service_params = Hashie::Mash.new(
      :provider      => provider,
      :name          => name,
      :service_level => service_level,
      :contacts      => [contact_info],
      :servers       => {
        :location  => location,
        :flavor    => "db.m3.large",
        :engine    => "postgres",
        :version   => "9.3.5",
        :modifiers => { :multi_az => true },
      })


    database_service = client.database_services.create(database_service_params).resource!

    expect(database_service.id).to be
    expect(database_service.name).to eq(database_service_params.name)
    expect(database_service.provider).to eq(provider)
    expect(database_service.servers.size).to eq(1)


    expect(database_service.service_level).to eq('level-2')
    expect(database_service.contacts).not_to be_nil

    contact = database_service.contacts.first
    expect(contact.name).to         eq(contact_info[:name])
    expect(contact.title).to        eq(contact_info[:title])
    expect(contact.email).to        eq(contact_info[:email])
    expect(contact.phone_number).to eq(contact_info[:phone_number])

  end

  it "should create a database service" do
    name     = Faker::Name.first_name
    location = "us-west-2c"

    database_service_params = Hashie::Mash.new(
      :provider        => provider,
      :name            => name,
      :service_level   => 'self-service',
      :database_server => {
        :location  => location,
        :flavor    => "db.m3.large",
        :engine    => "postgres",
        :version   => "9.3.5",
        :modifiers => { :multi_az => true },
      })

    database_service = client.database_services.create!(database_service_params).resource!

    expect(database_service.id).not_to be_nil
    expect(database_service.name).to eq(database_service_params.name)
    expect(database_service.provider).to eq(database_service_params.provider)
    expect(database_service.servers.size).to eq(1)

    server = database_service.servers.first
    expect(server.provider).to       eq(provider)
    expect(server.provisioned_id).to eq("#{name.downcase}master")
    expect(server.location).to       eq(location)
    expect(server.engine).to         eq(database_service_params.database_server.engine)
    expect(server.version).to        eq(database_service_params.database_server.version)
    expect(server.modifiers).to      eq(database_service_params.database_server.modifiers)
    expect(server.endpoint).not_to   be_nil
    expect(server.master?).to        be_truthy

    firewall = client.firewalls.last
    expect(server.firewalls).to  contain_exactly(firewall)
    expect(firewall.location).to eq("us-west-2")
    expect(firewall.provider).to eq(provider)
  end

  context "with a database service" do
    let!(:database_service) { create_database_service(provider: provider, client: client) }
    let!(:logical_database) { create_logical_database(client: client, database_service: database_service) }

    it "should destroy a database service" do

      firewall = database_service.servers.first.firewalls.first

      expect {
        database_service.destroy.ready!
      }.to change  { database_service.reload.deleted_at }.from(nil).
        and change { client.database_servers.size }.by(-database_service.servers.size).
        and change { client.logical_databases.size }.by(-database_service.databases.size).
        and change { firewall.reload.deleted_at }.from(nil)
    end

    it 'should list database services in an environment' do
      environment_database_service, environment = load_blueprint

      expect(environment.database_services).to contain_exactly(environment_database_service)

      expect(client.get_environment_database_services(environment_id: environment.id).body["database_services"].first["id"]).to eq(environment_database_service.id)
    end
  end
end
