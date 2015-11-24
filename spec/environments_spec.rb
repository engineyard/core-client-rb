require 'spec_helper'

describe 'as a user' do
  let(:client) { create_client }

  context "with an account" do
    let!(:account)  { create_account(client: client) }
    let!(:provider) { create_provider(account: account) }
    let!(:app)      { create_application(account: account, client: client) }

    it "does not create an environment without an application" do
      expect {
        client.environments.create!(name: Faker::Name.first_name, account: account)
      }.to raise_error(ArgumentError)
    end

    it "creates an environment" do
      name = Faker::Name.first_name

      environment = create_environment(account: account, application: app, environment: {name: name}, boot: false)
      expect(environment.name).to eq(name)
      expect(environment.classic).to eq(true)
    end

    context "with a database service" do
      let(:database_service) { create_database_service(provider: provider) }

      it "creates an environment with a logical database" do
        name = SecureRandom.hex(4)
        expect {
          create_environment(account: account, application: app, database_service: database_service, environment: {name: name})
        }.to change { account.environments.count }.by(1).and change { client.logical_databases.count }.by(1)

        environment      = client.environments.first(name: name)
        expect(environment.logical_databases.count).to eq(1)
        logical_database = environment.logical_databases.first
        expect(logical_database.name).to eq("#{environment.name}_#{app.name}")
      end
    end

    context "alerting environments", :mock_only do
      let(:legacy_alert)         { client.legacy_alerts.get(1001) }
      let(:server)               { client.servers.first }
      let(:alerting_environment) { create_environment(account: account, application: app, environment: { name: Faker::Name.first_name}) }
      let(:other_environment)    { create_environment(enviroment: { name: Faker::Name.first_name}, application: app, account: account) }

      before do
        pending "adding servers to environments not yet implemented"
        create_server(client,
                       provisioned_id: "i-a1000fce",
                             provider: provider,
                          environment: alerting_environment,
                                state: "running")

        create_legacy_alert(client,
                                type: "cpu",
                            severity: "warning",
                              server: server,
                        acknowledged: false)
      end

      it "lists alerting environments" do
        environments = client.environments.alerting
        expect(environments).to include(alerting_environment)
        expect(environments).not_to include(other_environment)
      end
    end

    context "with an environment" do
      let!(:name)        { Faker::Name.first_name }
      let!(:environment) { create_environment(account: account, application: app, environment: {name: name}) }

      it "destroys an environment" do
        expect {
          environment.destroy.ready!
        }.to change { environment.reload.deleted_at }.from(nil)
      end

      it "searches for enviornment by name" do
        expect(client.environments.all(name: name).size).to eq(1)
        expect(client.environments.first(name: name)).to eq(environment)
      end

      it "gets an account's environments" do
        expect(account.environments.all.map(&:identity)).to contain_exactly(environment.identity)
      end

      it "adds a keypair" do
        client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key)
      end

      it "deploys the application" do
        environment.deploy(app, ref: "HEAD").resource! # dont explode
      end
    end

    context "with multiple environments" do
      it "should list all environments"
    end
  end

  context "with multiple accounts" do
    it "should list all environments"
    it "should list an account's environments"
  end
end
