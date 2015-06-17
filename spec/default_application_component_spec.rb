require 'spec_helper'

# These specs assert behavior produced by actually running code on instances
# These are marked as mock_only as running them for "real" against an
# awsm-mocked would not produce the expected results
describe "default_application_component", :mock_only do
  let!(:client)                { create_client }
  let!(:account)               { create_account(client: client) }
  let!(:provider)              { create_provider(account: account) }
  let!(:application_component) { client.components.all(name: "default_deployer").one }
  let!(:cookbooks_component)   { client.components.all(name: "cluster_cookbooks").one }

  context "an environment with webapp cluster" do
    let!(:application)  { account.applications.create!(name: SecureRandom.hex(6), type: "rails3", repository: "git://github.com/engineyard/todo.git") }
    let!(:environment)  { account.environments.create!(account: account, name: Faker::Name.first_name) }
    let!(:cluster)      { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }
    let!(:cookbooks_cc) { cluster.cluster_components.create!(component: cookbooks_component, configuration: {facets: [{type: :ruby}, {type: :web_server}]}) }
    let!(:app_cc)       { cluster.cluster_components.create!(component: application_component, configuration: {application: application.id}) }

    describe "the 'deploy' action" do
      context "enabled status is not set" do
        before do
          expect(app_cc.configuration["enabled"]).to be_nil
        end
      
        it "defaults the enabled status to true" do
          expect(app_cc.run("deploy")).to be_successful
          expect(app_cc.reload.configuration["enabled"]).to eq(true)
        end
      end

      context "enabled status is set" do
        before do
          app_cc.configuration["enabled"] = false
          app_cc.save
        end
      
        it "does not change the enabled status" do
          expect(app_cc.run("deploy")).to be_successful
          expect(app_cc.reload.configuration["enabled"]).to eq(false)
        end
      end
    end

    describe "the 'disable' action" do
      context "the app is enabled" do
        before do
          app_cc.configuration["enabled"] = true
          app_cc.save
        end

        it "changes the enabled status" do
          expect(app_cc.run("disable")).to be_successful
          expect(app_cc.reload.configuration["enabled"]).to eq(false)
        end
      end
    end

    describe "the 'disable' action" do
      context "the app is disabled" do
        before do
          app_cc.configuration["enabled"] = false
          app_cc.save
        end

        it "changes the enabled status" do
          expect(app_cc.run("enable")).to be_successful
          expect(app_cc.reload.configuration["enabled"]).to eq(true)
        end
      end
    end
  end
end
