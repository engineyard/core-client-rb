require 'spec_helper'

describe "as a client" do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  context "with a database service" do
    let!(:database_service) { create_database_service(provider: provider, client: client) }

    it "creates a logical database" do
      logical_database = nil
      name = SecureRandom.hex(6)
      extensions = ["postgis"]

      expect {
        logical_database = database_service.databases.create!(name: name, extensions: extensions).resource!
      }.to change { client.logical_databases.size }.by(1)

      expect(logical_database.name).to         eq(name)
      expect(logical_database.username).not_to be_nil
      expect(logical_database.password).not_to be_nil
      expect(logical_database.extensions).to   eq(extensions)
      expect(logical_database.service).to      eq(database_service)
    end

    context "with a logical database" do
      let!(:logical_database) { create_logical_database(client: client, database_service: database_service) }

      it "destroys the logical database" do
        expect {
          logical_database.destroy.ready!
        }.to change  { logical_database.reload.deleted_at }.from(nil).
          and change { database_service.databases.reload.all.size }.by(-1)
      end
    end
  end
end
