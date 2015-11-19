require 'spec_helper'

describe "as a user" do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { create_environment(account: account, name: Faker::Name.first_name) }
  let!(:keypair)     { client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key) }

  it "creates a keypair deployment" do
    keypair_deployment = client.keypair_deployments.create(keypair: keypair, environment: environment)

    expect(keypair_deployment.identity).not_to be_nil
    expect(keypair_deployment.keypair).to eq(keypair)
    expect(keypair_deployment.environment).to eq(environment)
  end

  context "with a keypair deployment" do
    let!(:keypair_deployment) { client.keypair_deployments.create(keypair: keypair, environment: environment) }

    it "lists the keypair deployment" do
      expect(client.keypair_deployments.all).to include(keypair_deployment)
    end

    it "lists an environment's keypairs" do
      expect(environment.keypairs.all.to_a).to eq([keypair])
    end

    it "lists a keypair's deployments"
    it "searches keypairs by name"
    it "searches keypairs by fingerprint"
  end
end
