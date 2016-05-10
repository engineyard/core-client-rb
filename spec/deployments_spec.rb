require 'spec_helper'

describe "deployments" do
  let!(:client) { create_client }
  let!(:account) { create_account(client: client) }
  let!(:application) { create_application(account: account) }
  let!(:environment) { create_environment(account: account, application: application, name: Faker::Name.first_name) }

  before(:each) { environment.deploy(application, ref: "HEAD").resource! }

  it "lists deployments" do
    expect(environment.deployments).not_to be_empty
    deployment = environment.deployments.first
    expect(deployment.reload).to be
  end

  it "times out a deployment" do
    deployment = environment.deployments.first

    expect {
      deployment.timeout
    }.to change { deployment.reload.successful }.to(false)
  end
end
