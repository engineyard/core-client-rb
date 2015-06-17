require 'spec_helper'

RSpec.describe Ey::Core::Client do
  let!(:client)   { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  # @note private
  it "creates an untracked server" do
    provisioner_id = SecureRandom.uuid
    location       = "us-west-2b"
    provisioned_id = "i-#{SecureRandom.hex(4)}"
    state          = "found"

    untracked_server = provider.untracked_servers.create(
      :provisioner_id => provisioner_id,
      :location       => location,
      :provisioned_id => provisioned_id,
      :state          => state,
    )

    expect(untracked_server.provisioner_id).to eq(provisioner_id)
    expect(untracked_server.provisioned_id).to eq(provisioned_id)
    expect(untracked_server.location).to       eq(location)
    expect(untracked_server.provider).to       eq(provider)
    expect(untracked_server.state).to          eq(state)

    untracked_server.reload

    expect(untracked_server.provisioner_id).to eq(provisioner_id)
    expect(untracked_server.provisioned_id).to eq(provisioned_id)
    expect(untracked_server.location).to       eq(location)
    expect(untracked_server.provider).to       eq(provider)
    expect(untracked_server.state).to          eq(state)

    untracked_server = client.untracked_servers.get!(untracked_server.identity)

    expect(untracked_server.provisioner_id).to eq(provisioner_id)
    expect(untracked_server.provisioned_id).to eq(provisioned_id)
    expect(untracked_server.location).to       eq(location)
    expect(untracked_server.provider).to       eq(provider)
    expect(untracked_server.state).to          eq(state)
  end

  context "with an untracked server" do
    let!(:untracked_server) { create_untracked_server(provider: provider) }

    it "should update server" do
      expect {
        untracked_server.update(state: "killed")
      }.to change { untracked_server.reload.state }.to("killed")
    end

    it "lists untracked servers" do
      expect(client.untracked_servers.all).to contain_exactly(untracked_server)
      expect(provider.untracked_servers.all).to contain_exactly(untracked_server)
    end
  end
end
