require 'spec_helper'

describe 'servers' do
  let!(:client)   { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  context "with a legacy server", :mock_only do
    let!(:environment) { account.environments.create(name: Faker::Name.name) }
    let!(:server) {
      create_server(client,
                    provisioned_id: "i-a1000fce",
                    provider: provider,
                    environment: environment,
                    state: "running")
    }

    it "has an association with the environment" do
      expect(server.environment).to eq(environment)
    end

    it "reboots" do
      reboot_request = server.reboot
      reboot_request.ready!
      expect(reboot_request.successful).to be true
    end

    it "destroys" do
      expect {
        server.destroy.ready!
      }.to change { server.reload.deleted_at }.from(nil)
    end

    it "lists servers by provider" do
      expect(provider.servers).to contain_exactly(server)
    end
  end

  context "with nextgen servers" do
    let!(:environment)         { account.environments.create!(name: SecureRandom.hex(6)) }
    let!(:another_environment) { account.environments.create!(name: SecureRandom.hex(6)) }
    let!(:cluster)             { environment.clusters.create!(name: "one", provider: provider, location: "us-west-2") }
    let!(:another_cluster)     { another_environment.clusters.create!(name: "two", provider: provider, location: "us-west-2") }

    let(:server)         { @server }
    let(:another_server) { @another_server }

    before(:each) do
      slot = cluster.slots.create(quantity: 1).first
      cluster.cluster_updates.create!.ready!
      @server = slot.reload.server
      expect(server).to be_a(Ey::Core::Client::Server)

      another_slot = another_cluster.slots.create!(quantity: 1).first

      another_cluster.cluster_updates.create!.ready!
      @another_server = another_slot.reload.server
      expect(another_server).to be_a(Ey::Core::Client::Server)
    end

    it "gets device info aka block device map" do
      expect(server.devices).to be
    end

    it "lists servers" do
      expect(client.servers.all).to contain_exactly(server, another_server)
    end

    it "updates a server" do
      disappeared_at = Time.now

      expect {
        server.update!(disappeared_at: disappeared_at)
      }.to change { server.reload.disappeared_at }.from(nil).to(disappeared_at)
    end

    it "updates a server's state" do
      expect {
        server.update!(state: "decommissioning")
      }.to change { server.reload.state }.from("running").to("decommissioning")
    end

    it "lists an environment's servers" do
      expect(environment.servers.all).to match_array([server])
      expect(another_environment.servers.all).to match_array([another_server])
    end

    it "lists a cluster's servers" do
      expect(cluster.servers.all).to match_array([server])
      expect(another_cluster.servers.all).to match_array([another_server])
    end

    it "searches by provisioned_id" do
      expect(client.servers.all(provisioned_id: server.provisioned_id)).to match_array([server])
      expect(client.servers.all(provisioned_id: another_server.provisioned_id)).to match_array([another_server])
    end

    it "terminates the server" do
      expect {
        server.destroy!.ready!
      }.to change { cluster.servers.count }.by(-1)
    end
  end
end
