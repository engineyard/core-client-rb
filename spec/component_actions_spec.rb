require 'spec_helper'

describe "component actions" do
  let!(:client)  { create_client }
  let!(:account) { create_account(client: client) }

  let!(:provider) { account.providers.all.first || account.providers.create!(type: "aws").resource! }
  let!(:app_component) { client.components.all(name: "default_deployer").one }
  let!(:cookbooks_component) { client.components.all(name: "cluster_cookbooks").one }

  describe "cluster updates" do
    #
    # cluster updates definitely spawn component actions sometimes,
    # I'm not exactly sure when and how, so I'm leaving this empty for now
    #
    it "should have tests"

    context "updating a 3 slot cluster" do
      let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
      let!(:cluster) { cluster = environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2").tap {|c| c.slots.create(quantity: 5) } }
      let!(:cluster_update) { cluster.cluster_updates.create! }
    end
  end

  describe "application deploys" do

    context "environment with app cluster" do
      let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
      let!(:cluster) { environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2") }
      let!(:application) { account.applications.first(account: account.id, name: "todo") || account.applications.create!(name: :todo, type: "rails3", repository: "git://github.com/engineyard/todo.git") }
      let!(:app_cluster_component) { cluster.cluster_components.create!(component: app_component, configuration: {application: application.id}) }
      let!(:slots) { cluster.slots.create(quantity: 2) }

      before(:each) do
        cluster.cluster_updates.create!.ready!
      end

      it "creates a task with a component action?" do
        task = cluster.deploy(application).resource!
        expect(task).to be_successful

        component_action = task.component_actions.find{|ca| ca.command.include?("deploy")}
        expect(component_action).to be_successful

        expect(component_action.account).to eq(account)
        expect(component_action.command).to include("engineyard-serverside")
        expect(component_action.dependencies_url).to eq(nil)
        expect(component_action.exit_code).to eq(0)
        expect(component_action.task).to eq(task)

        log = component_action.logs.one
        expect(log.component_action).to eq(component_action)
        expect(log.download_url).not_to be_empty
        expect(log.filename).to eq("command.txt")
        expect(log.mime_type).to eq("text/plain")
      end

    end
  end

  describe "backups?" do
    #
    # Backups definitely spawn component actions sometimes,
    # I'm not exactly sure when and how, so I'm leaving this empty for now
    #

    it "should have tests"
  end
end
