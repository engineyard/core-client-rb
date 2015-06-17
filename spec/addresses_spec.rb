require 'spec_helper'

describe 'addresses' do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }

  it "should create an address" do
    request = client.addresses.create!(provider: provider, location: "us-west-2")
    address = request.resource!
    expect(address.id).not_to be_nil
    expect(address.ip_address).not_to be_nil
    expect(address.provisioned_id).not_to be_nil
    expect(address.provider).to eq(provider)
  end

  context "with an address" do
    let(:location) { "us-west-2" }
    let!(:address)  { client.addresses.all.find{|a| a.location.match(location) && a.server_id.nil?} || client.addresses.create!(provider: provider, location: location).resource! }

    it "should search by provisioned_id" do
      addresses = client.addresses.all(provisioned_id: address.provisioned_id)
      expect(addresses.size).to eq(1)
      expect(addresses.first).to eq(address)
    end

    it "should search by ip_address" do
      addresses = client.addresses.all(ip_address: address.ip_address)
      expect(addresses.size).to eq(1)
      expect(addresses.first).to eq(address)
    end

    it "should list addresses" do
      addresses = client.addresses.all
      expect(addresses.to_a).to include(address)
      expect(address.id).not_to be_nil
      expect(address.ip_address).not_to be_nil
      expect(address.provisioned_id).not_to be_nil
      expect(address.provider).to eq(provider)
      expect(address).to respond_to(:server)
    end

    context "with a server" do
      let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
      let!(:cluster)     { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: location) }
      let!(:slots)       { cluster.slots.create(quantity: 2) }

      before(:each) { cluster.cluster_updates.create!.ready! }

      it "should attach and detach an address from a server" do
        servers = client.servers.all

        attached_server = servers.find { |s| s.location.match(location) && s.address.nil? }
        expect(attached_server).not_to be_nil

        address.attach(attached_server).ready!

        address = attached_server.reload.address
        address.detach.ready!

        expect(attached_server.reload.address).to be_nil
        expect(address.reload.server).to be_nil
      end
    end
  end
end
