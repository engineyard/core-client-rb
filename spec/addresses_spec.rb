require 'spec_helper'

describe 'addresses' do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it "creates an address" do
    request = client.addresses.create!(provider: provider, location: "us-west-2", scope: "vpc")
    address = request.resource!
    expect(address.id).not_to be_nil
    expect(address.ip_address).not_to be_nil
    expect(address.provisioned_id).not_to be_nil
    expect(address.provider).to eq(provider)
    expect(address.scope).to eq("vpc")
  end

  context "with an address" do
    let(:location) { "us-west-2" }
    let!(:address) { client.addresses.all.find{|a| a.location.match(location) && a.server_id.nil?} || client.addresses.create!(provider: provider, location: location).resource! }

    it "searches by provisioned_id" do
      addresses = client.addresses.all(provisioned_id: address.provisioned_id)
      expect(addresses.size).to eq(1)
      expect(addresses.first).to eq(address)
    end

    it "searches by ip_address" do
      addresses = client.addresses.all(ip_address: address.ip_address)
      expect(addresses.size).to eq(1)
      expect(addresses.first).to eq(address)
    end

    it "lists addresses" do
      addresses = client.addresses.all
      expect(addresses.to_a).to include(address)
    end

    context "with a server" do
      let!(:environment) { create_environment(account: account, name: Faker::Name.first_name, configuration: {"type" => "cluster"}) }

      it "attaches and detach an address from a server" do
        server = environment.servers.first(role: "app_master")

        expect(server).to be

        address.attach(server).ready!

        address = server.reload.address
        address.detach.ready!

        expect(server.reload.address).to be_nil
        expect(address.reload.server).to be_nil
      end
    end
  end
end
