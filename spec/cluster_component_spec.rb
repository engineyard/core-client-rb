require 'spec_helper'

describe "cluster components" do
  let!(:client) { create_client }
  let!(:user)        { client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
  let!(:client)      { create_client }
  let!(:account)     { client.accounts.get(client.accounts.create!(owner: user, name: Faker::Name.first_name, type: "beta").id) }

  let!(:provider) { account.providers.all.first || account.providers.create!(type: "aws").resource! }
  let!(:app_component) { client.components.all(name: "default_deployer").one }
  let!(:cookbooks_component) { client.components.all(name: "cluster_cookbooks").one }

  describe "application component" do
    context "an environment with an app cluster and servers" do
      let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
      let!(:cluster) { environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2") }
      let!(:application) { account.applications.first(name: "todo") || account.applications.create!(name: :todo, type: "rails3", repository: "git://github.com/engineyard/todo.git") }
      let!(:app_cluster_component) { cluster.cluster_components.create!(component: app_component, configuration: {application: application.id}) }
      let!(:slots) { cluster.slots.create(quantity: 2) }

      before(:each) { cluster.cluster_updates.create!.ready! }

      describe "deploying" do
        let!(:task) { app_cluster_component.run("deploy", foo: "bar").resource! }

        it "creates a task with given data" do
          expect(task).to be_successful
          expect(task.configuration).to include("foo" => "bar")
          expect(task.action).to eq("deploy")
        end

        it "associates the task with the cluster component and vice-versa" do
          expect(task.respond_to?(:cluster_component)).to be_falsey #core tasks do not have cluster component key
          expect(app_cluster_component.tasks).to include(task)
        end

        it "creates a component action to run serverside on one of the slots" do
          actions = task.component_actions.all
          expect(actions.size).to eq(2)

          action = actions.last
          expect(action.command).to include("engineyard-serverside")
          expect(action.command).to include("deploy")
        end
      end

      describe "enabling the app" do
        let!(:task) { app_cluster_component.run("enable", foo: "bar").resource! }

        it "creates a task with given data" do
          expect(task).to be_successful
          expect(task.configuration).to include("foo" => "bar")
          expect(task.action).to eq("enable")
        end

        it "creates a component action to run serverside on one of the slots" do
          actions = task.component_actions.all
          expect(actions.size).to eq(2)

          action = actions.last
          expect(action.command).to include("engineyard-serverside")
          expect(action.command).to include("disable_maintenance")
        end
      end


      describe "disabling the app" do
        let!(:task) { app_cluster_component.run("disable", foo: "bar").resource! }

        it "creates a task with given data" do
          expect(task).to be_successful
          expect(task.configuration).to include("foo" => "bar")
          expect(task.action).to eq("disable")
        end

        it "creates a component action to run serverside on one of the slots" do
          actions = task.component_actions.all
          expect(actions.size).to eq(2)

          action = actions.last
          expect(action.command).to include("engineyard-serverside")
          expect(action.command).to include("enable_maintenance")
        end
      end

      describe "restarting the app" do
        let!(:task) { app_cluster_component.run("restart", foo: "bar").resource! }

        it "creates a task with given data" do
          expect(task).to be_successful
          expect(task.configuration).to include("foo" => "bar")
          expect(task.action).to eq("restart")
        end

        it "creates a component action to run serverside on one of the slots" do
          actions = task.component_actions.all
          expect(actions.size).to eq(2)

          action = actions.last
          expect(action.command).to include("engineyard-serverside")
          expect(action.command).to include("restart")
        end
      end
    end
  end
end
