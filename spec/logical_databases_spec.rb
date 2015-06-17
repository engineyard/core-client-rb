require 'spec_helper'

describe "as a client" do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }


  context "with a database service" do
    let!(:database_service) { create_database_service(provider: provider, client: client) }

    it "should create a logical database" do
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

      it "should get the logical database" do
        expect(client.logical_databases.get(logical_database.id)).to eq(logical_database)
      end

      it "should destroy the logical database" do
        expect {
          logical_database.destroy.ready!
        }.to change  { logical_database.reload.deleted_at }.from(nil).
          and change { database_service.databases.reload.all.size }.by(-1)
      end

      context "with an application cluster" do
        let!(:application)           { account.applications.create!(name: "todo", repository: "git://github.com/engineyard/todo.git", type: "rails3") }
        let!(:environment)           { account.environments.create!(name: "environment") }
        let!(:www_cluster)           { environment.clusters.create!(provider: provider, location: "us-west-2", name: "app", release_label: "ubuntu-1.0") }
        let!(:app_component)         { client.components.first(name: "default_deployer") }
        let!(:www_cluster_component) { www_cluster.cluster_components.create!(component: app_component, configuration: { application: application.id}) }

        it "should connect the application and logical database" do
          expect {
            logical_database.connect(www_cluster_component)
          }.to change { www_cluster_component.connectors.reload.count }.by(1)
        end

        it 'should list logical databases in environment' do
          logical_database.connect(www_cluster_component)

          load_blueprint(client: client) #for another env

          expect(environment.logical_databases).to contain_exactly(logical_database)
          expect(client.get_environment_logical_databases(environment_id: environment.id).body["logical_databases"].first["id"]).to eq(logical_database.id)
        end

        context 'bootstrap' do
          let(:logical_database_name) { "something#{SecureRandom.hex(4)}" }
          let!(:cluster_component)    { environment.clusters.first.cluster_components.first }
          let(:cluster_components)    { [cluster_component.id] }

          it 'should create logical database with new database service' do
            database_server_params = Hashie::Mash.new(
              :flavor    => "db.m3.large",
              :engine    => "postgres",
              :version   => "9.3.5",
              :location  => "us-west-2a",
              :storage   => 100,
              :modifiers => { multi_az: true, storage_type: "io1", iops: "1000" },
            )
            database_service_params = Hashie::Mash.new(:name  => "service#{SecureRandom.hex(4)}")
            logical_database_params = { name: logical_database_name }

            logical_database = nil
            expect {
              logical_database = client.logical_databases.bootstrap(
                provider:           provider.id,
                database_service:   database_service_params,
                database_server:    database_server_params,
                logical_database:   logical_database_params,
                cluster_components: cluster_components,
              ).resource!
            }.to change { client.logical_databases.size }.by(1)

            expect(logical_database.id).not_to be_nil
            expect(logical_database.name).to eq(logical_database_name)
            expect(logical_database.username).not_to be_nil
            expect(logical_database.password).not_to be_nil

            database_service = logical_database.service
            expect(database_service.name).to eq(database_service_params.name)

            database_server = database_service.servers.first
            expect(database_server.flavor).to eq(database_server_params.flavor)
            expect(database_server.engine).to eq(database_server_params.engine)
            expect(database_server.version).to eq(database_server_params.version)
            expect(database_server.storage).to eq(database_server_params.storage)
            expect(database_server.modifiers).not_to be_nil
          end

          it 'should create logical database with exisiting database service' do
            given_database_service = create_database_service(provider: provider, client: client)
            logical_database_params = { name: logical_database_name }

            logical_database = nil
            expect {
              logical_database = client.logical_databases.bootstrap(
                provider:           provider.id,
                database_service:   given_database_service.id,
                logical_database:   logical_database_params,
                cluster_components: cluster_components,
              ).resource!
            }.to change { client.logical_databases.size }.by(1)

            expect(logical_database.id).not_to be_nil
            expect(logical_database.name).to eq(logical_database_name)
            expect(logical_database.username).not_to be_nil
            expect(logical_database.password).not_to be_nil

            database_service = logical_database.service
            expect(database_service).to eq(given_database_service)
          end
        end
      end
    end
  end
end
