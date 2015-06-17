require 'spec_helper'

describe 'application deployments' do
  describe "as a user" do
    let(:client)       { create_client }
    let!(:account)     { create_account(client: client) }
    let!(:provider)    { create_provider(account: account) }
    let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
    let!(:cluster)     { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }
    let!(:application) { account.applications.create!(name: SecureRandom.hex(6), type: "rails3", repository: "git://github.com/engineyard/todo.git") }

    describe "with a cluster" do
      before(:each) do
        default_component = client.components.first(name: "cluster_cookbooks")
        expect(default_component).not_to be_nil
        default_application_component = client.components.first(name: "default_deployer")

        cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :ruby}, {type: :web_server}]})
        cluster.cluster_components.create!(component: default_application_component, configuration: {application: application.id})
        cluster.slots.create(quantity: 2, flavor: "large")

        update_request = cluster.cluster_updates.create!
        update_request.ready!(20, 1)
      end

      it "should deploy an application" do
        task = cluster.deploy(application).resource!
        expect(task.successful).to be true

        deployment = task.application_deployment
        expect(deployment).to be

        expect(deployment.application).to eq(application)
      end

      it "should include task data" do
        task = cluster.deploy(application,
          :commit          => "12345abc",
          :migrate         => true,
          :migrate_command => "echo 'migrated'",
          :ref             => "rando_branch",
          :something       => "else"
        ).resource!

        expect(task.configuration).to include(
          "commit"          => "12345abc",
          "migrate"         => true,
          "migrate_command" => "echo 'migrated'",
          "ref"             => "rando_branch",
          "something"       => "else",
        )

        deployment = task.application_deployment
        expect(deployment).to be

        expect(deployment.ref).to eq("rando_branch")
        expect(deployment.commit).to eq("12345abc")
      end

      describe "with an application archive" do
        let!(:archive) { application.archives.create!(filename: "helloservlet.war") }

        it "should deploy the archive" do
          task = cluster.deploy(application, archive: archive).resource!
          expect(task.successful).to be true

          deployment = task.application_deployment
          expect(deployment.archive).to eq(archive)
        end
      end

      describe "with a deploymet" do
        let!(:application_deployment) { task.application_deployment }
        let!(:task)                   { cluster.deploy(application).resource! }

        it "should get an application deployment" do
          expect(client.application_deployments.get(application_deployment.identity)).to eq(application_deployment)

          application_deployment.reload

          expect(application_deployment.ref).not_to be_nil
          expect(application_deployment.commit).not_to be_nil
          expect(application_deployment.created_at).not_to be_nil
          expect(application_deployment.finished_at).not_to be_nil
          expect(application_deployment.migrate_command).not_to be_nil
          expect(application_deployment.serverside_version).not_to be_nil
          expect(application_deployment.started_at).not_to be_nil
          expect(application_deployment.successful).to eq(task.successful)

          expect(application_deployment.task).to        eq(task)
          expect(application_deployment.application).to eq(application)
        end

      it "should be authorized to the channel", :mock_only do
        authorized_task = client.authorized_channel(Addressable::URI.parse(task.read_channel).query_values["subscription"]).body["task"]
        expect(authorized_task["id"]).to eq(task.identity)
      end

      it "should not be authorized to a made up channel" do
        expect { client.authorized_channel("/tasks/staff") }.to raise_exception(Ey::Core::Response::NotFound)
      end

        it "should list all application deployments" do
          expect(client.application_deployments.all).to match_array([application_deployment])
        end
      end
    end

    describe "with multiple deployed clusters" do
      it "should list all deployments"
      it "should list a cluster's deployments"
      it "should list an environment's deployments"
    end
  end
end
