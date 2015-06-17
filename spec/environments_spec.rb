require 'spec_helper'

describe 'as a user' do
  let(:client) { create_client }

  context "with an account" do
    let!(:account)  { create_account(client: client) }
    let!(:provider) { create_provider(account: account) }

    it "should create an environment" do
      name = Faker::Name.first_name

      environment = account.environments.create!(name: name)
      expect(environment.name).to eq(name)
      expect(environment.classic).to eq(false)
    end

    it "should destroy an environment" do
      name = Faker::Name.first_name

      environment = account.environments.create(name: name)
      request_id = nil
      expect { request_id = environment.destroy.ready!.identity }.to change { client.environments.all.size }.by(-1)
      expect(environment.reload.deleted_at).to be

      client.requests.get(request_id).resource! # don't explode
    end

    it "should search for enviornment by name" do
      name = Faker::Name.first_name

      environment = client.environments.create!(account: account, name: name)
      client.environments.create!(account: account, name: Faker::Name.first_name)

      expect(client.environments.all(name: name).size).to eq(1)
      expect(client.environments.first(name: name)).to eq(environment)
    end

    it "should get an account's environments" do
      environment = account.environments.create(name: Faker::Name.first_name)

      expect(account.environments.all.map(&:identity)).to eq([environment.identity])
    end

    context "alerting environments", :mock_only do
      let(:legacy_alert) { client.legacy_alerts.get(1001) }
      let(:server) { client.servers.first }
      let(:alerting_environment) { account.environments.create(name: Faker::Name.first_name) }
      let(:other_environment) { account.environments.create(name: Faker::Name.first_name) }

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

      it "should list alerting environments" do
        environments = client.environments.alerting
        expect(environments).to include(alerting_environment)
        expect(environments).not_to include(other_environment)
      end
    end

    context "with an environment" do
      let(:environment) { account.environments.create(name: Faker::Name.first_name) }

      it "should add a keypair" do
        client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key)
      end

      context "with an app cluster" do
        let(:application) { account.applications.first(account: account.id, name: "todo") || account.applications.create!(name: :todo, type: "rails3", repository: "git://github.com/engineyard/todo.git") }
        before(:each) do
          default_component = client.components.first(name: "cluster_cookbooks")
          expect(default_component).not_to be_nil
          default_application_component = client.components.first(name: "default_deployer")
          expect(default_application_component).not_to be_nil

          cluster_release_label = "ubuntu-1.1"
          cluster = client.clusters.create!(provider: provider, location: "us-west-2", environment: environment, name: "www", release_label: cluster_release_label)
          cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :ruby}, {type: :web_server}]})
          cluster.cluster_components.create!(component: default_application_component, configuration: {application: application.id})
          cluster.slots.create(quantity: 2, flavor: "large", image: "dpiddy")
          cluster.cluster_updates.create!.ready!
        end

        it "should deploy an application" do
          task = environment.deploy(application, foo: "bar").resource!
          expect(task.action).to eq("deploy")
          expect(task.configuration["foo"]).to eq("bar")
        end

        it "should run any app action" do
          %w[deploy enable disable restart].each do |action|
            task = environment.run_action(application, action, foo: "bar").resource!
            expect(task.action).to eq(action)
            expect(task.configuration["foo"]).to eq("bar")
          end
        end
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
