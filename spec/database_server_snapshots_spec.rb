require 'spec_helper'

describe "as a client" do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  context "with a database server" do
    let!(:database_service) { create_database_service(provider: provider, client: client) }
    let!(:database_server)  { database_service.servers.first }

    it "should discover database server snapshots", :mock_only do
      expect {
        snapshots = client.database_server_snapshots.discover(provider).resource!
        expect(snapshots).to be_a(Ey::Core::Client::DatabaseServerSnapshots)
        expect(snapshots.count).not_to eq(0)
      }.to change { database_server.snapshots.count }
    end

    it "creates a snapshot" do
      snapshot = database_server.snapshots.create.resource!

      expect(snapshot.database_server).to eq(database_server)
      expect(snapshot.database_service).to eq(database_service)
      expect(snapshot.provisioned_id).to be

      expect(database_service.snapshots).to contain_exactly(snapshot)
      expect(database_server.snapshots).to  contain_exactly(snapshot)
    end

    context "with a snapshot" do
      let!(:snapshot) { database_server.snapshots.create.resource! }

      it "destroys" do
        expect {
          snapshot.destroy!.resource!
        }.to change { snapshot.reload.deleted_at }.from(nil)
      end
    end
  end
end
