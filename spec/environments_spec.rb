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

      context "and the environment is permanently ignored", mock_only: true do
        before(:each) do
          client.data[:environments][alerting_environment.id]["permanently_ignored"] = true
        end

        it "returns the ignored environment by default" do
          expect(client.environments.alerting).to contain_exactly(alerting_environment)
        end

        it "filters it if you tell it to" do
          expect(client.environments.alerting("exclude_ignored" => true)).to be_empty
        end
      end
    end

    context "with an environment" do
      let!(:name)        { Faker::Name.first_name }
      let!(:environment) { create_environment(account: account, application: app, environment: {name: name}, configuration: {type: "production"}) }

      describe '#assignee' do
        let(:assignee) {client.environments.get(environment.id).assignee}

        context 'for an environment with an assignee' do
          let(:user) {create_user(client: client, creator: client)}

          before(:each) do
            # Since we can't set an assignee directly ...
            client.data[:environments][environment.id]['assignee_id'] = user.id
          end

          it 'is the user assigned to the environment' do
            expect(assignee).to eql(user)
          end
        end

        context 'for an environment without an assignee' do
          it 'is nil' do
            expect(assignee).to be_nil
          end
        end
      end

      describe '#unassign!' do
        let(:user) {create_user(client: client, creator: client)}

        let(:test_env) {account.environments.get(environment.id)}

        before(:each) do
          # Since we can't set an assignee directly ...
          client.data[:environments][environment.id]['assignee_id'] = user.id
        end

        it 'removes the assignment from the environment' do
          expect(test_env.assignee).not_to be_nil

          test_env.unassign!

          expect(test_env.assignee).to be_nil
        end
      end

      it "has the right number of servers" do
        expect(environment.servers.count).to eq(5)
      end

      it "creates a blueprint" do
        blueprint = nil
        expect {
          blueprint = environment.save_blueprint("name" => SecureRandom.hex(3))
        }.to change { environment.blueprints.count }.by(1)

        expect(blueprint.data["app_instances"].count).to eq(3)
        expect(blueprint.data["db_master"].count).to eq(1)
        expect(blueprint.data["db_slaves"].count).to eq(1)
      end

      it "applies main" do
        expect(environment.apply.ready!).to be_successful

        if Ey::Core::Client.mocking?
          expect(client.data[:instance_updates].count).to eq(environment.servers.count)
          expect(client.data[:instance_updates].values.map { |iu| iu["data"]["type"] }).to eq(["main"] * environment.servers.count)
        end
      end

      it "applies custom" do
        expect(environment.apply("custom").ready!).to be_successful

        if Ey::Core::Client.mocking?
          expect(client.data[:instance_updates].count).to eq(environment.servers.count)
          expect(client.data[:instance_updates].values.map { |iu| iu["data"]["type"] }).to eq(["custom"] * environment.servers.count)
        end
      end

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
