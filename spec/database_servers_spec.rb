require 'spec_helper'

describe "as a client" do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  context "with a database server" do
    let!(:database_service) { create_database_service(provider: provider, client: client) }
    let!(:database_server)  { database_service.servers.first }

    it "should list the database server" do
      expect(client.database_servers.all).to include(database_server)
    end

    context "and a bunch of others" do
      let!(:_) { create_database_service }

      it "should find a database server by provider" do
        expect(client.database_servers.all(provider: provider.id)).to contain_exactly(database_server)
      end
    end

    it "should add a message" do
      message = nil

      expect {
        message = database_server.messages.create(message: Faker::Lorem.sentence(1))
      }.to change { database_server.messages.size }.by(1)

      expect(database_server.messages.first).to eq(message)
    end

    it "should create a replica" do
      replica = client.database_servers.create!(provider: provider, replication_source: database_server).resource!

      expect(client.database_servers.all).to include(replica)
      expect(replica.replication_source).to  eq(database_server)
      expect(replica.database_service).to    eq(database_server.database_service)
      expect(replica.engine).to              eq(database_server.engine)
      expect(replica.version).to             eq(database_server.version)
      expect(replica.flavor).to              eq(database_server.flavor)
      expect(replica.location).to            eq(database_server.location)
      expect(replica.storage).to             eq(database_server.storage)
      expect(replica.modifiers).to           eq(database_server.modifiers)
      expect(replica.firewalls).not_to       be_nil

      expect(database_service.reload.servers).to contain_exactly(database_server, replica)
    end

    it "should rediscover a database server and list its revisions", :mock_only do
      expect {
        database_server.discover.ready!
      }.to change { database_server.reload.flavor }.and change { database_server.revisions.count }

      revision = database_server.revisions.first
      expect(revision.database_server).to eq(database_server)
      expect(revision.data).to have_key("flavor")
    end
  end
end
