require 'spec_helper'

describe 'networks' do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it "creates a network" do
    network = client.networks.create!(provider: provider, location: "us-east-2", cidr: "10.0.0.0/16").resource!
    expect(network.id).to be
    expect(network.location).to eq('us-east-2')
    expect(network.cidr).to eq('10.0.0.0/16')
    expect(network.subnets).not_to be_empty
  end

  it "creates a network and skips the subnets" do
    network = client.networks.create!(provider: provider, location: "us-east-2", cidr: "10.0.0.0/16", skip_subnets: true).resource!
    expect(network.subnets).to be_empty
  end

  context "with a network" do
    let(:network) { client.networks.create!(provider: provider, location: "us-east-2", cidr: "10.0.0.0/16").resource! }

    it "deletes a network" do
      expect {
        network.destroy.ready!
      }.to change { network.reload.deleted_at }.from(nil)
    end
  end
end
