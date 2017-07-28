require 'spec_helper'

describe 'servers' do
  let!(:client)      { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:application) { create_application(account: account) }

  context "with a solo environment" do

    let!(:environment) { create_environment(account: account, application: application, name: Faker::Name.first_name) }
    let!(:server)      { environment.servers.first }

    context "discovering" do
      it "discovers a server that it knows nothing about" do
        expect {
          client.servers.discover(provider: account.providers.first.identity, environment: environment.identity, server: {location: "us-east-1b", provisioned_id: "i-newserver"}).resource!
        }.to change { client.servers.count }.by(1)
      end
    end

    context "with a second account" do
      let(:account2) { create_account(client: client) }
      let(:app2)     { create_application(account: account2) }

      context "with a solo env" do
        let!(:environment2) { create_environment(account: account2, application: application, name: Faker::Name.first_name) }
        let!(:server2) { environment2.servers.first }

        it "filters servers by account" do
          expect(client.servers.all(account: account2).map(&:id)).to contain_exactly(server2.id)
        end
      end
    end

    it "has an association with the environment" do
      expect(server.environment).to eq(environment)
    end

    it "reboots" do
      reboot_request = server.reboot
      reboot_request.ready!
      expect(reboot_request.successful).to be true
    end

    it "stops" do
      request = server.stop
      request.ready!
      expect(request.successful).to be true
    end

    it "starts" do
      request = server.start
      request.ready!
      expect(request.successful).to be true
    end

    it "reconciles" do
      request = server.reconcile
      request.ready!
      expect(request.successful).to be true
    end

    it "applies" do
      expect(server.apply.ready!).to be_successful

      if Ey::Core::Client.mocking?
        expect(client.data[:instance_updates].count).to eq(1)
      end
    end

    it "should reset the server state" do
      expect {
        server.reset_state('error')
      }.to change { server.reload.state }.from('running').to('error')
    end

    it "does not destroy" do
      expect {
        server.destroy
      }.to raise_error(Ey::Core::Client::NotPermitted)
    end

    it "lists servers by environment" do
      expect(environment.servers).to contain_exactly(server)
    end

    it "searches for servers by role" do
      expect {
        environment.servers.all(role: "solo").to contain_exactly(server)
      }
    end

    it "adds a dedicated app server" do
      server = client.servers.create!(
        :environment => environment,
        :role        => "app",
        :flavor_id   => "m3.large",
        :dedicated   => true,
      ).resource!
      expect(server.dedicated).to be_truthy
    end

    it "adds an app server" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "app",
          :flavor_id   => "m3.large",
        ).resource!
      }.to change { environment.servers.count }.by(1)
    end

    it "adds a util server" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "util",
          :flavor_id   => "m3.large",
          :name        => "resque",
        ).resource!
      }.to change { environment.servers.count }.by(1)
    end

    it "does not add a util server without a name" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "util",
          :flavor_id   => "m3.large",
        ).resource!
      }.to raise_error(Ey::Core::Response::BadRequest, /value is empty: name/)
    end

    it "does not add a db slave" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "db_slave",
          :flavor_id   => "m3.large",
        )
      }.to raise_error(Ey::Core::Response::Unprocessable, /cannot add a db slave/i)
    end
  end

  context "with multiple servers" do
    let!(:environment) { create_environment(account: account, application: application, name: Faker::Name.first_name, configuration: {"type" => "cluster"}) }
    let!(:server)      { environment.servers.first }

    it "destroys" do
      expect {
        server.destroy.ready!
      }.to change { server.reload.deleted_at }.from(nil)
    end

    it "searches for servers by role" do
      expect(environment.servers.first(role: "app_master")).to be
      expect(environment.servers.first(role: "app")).to be
      expect(environment.servers.first(role: "db_master")).to be
    end

    it "adds an app server" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "app",
          :flavor_id   => "m3.large",
        ).resource!
      }.to change { environment.servers.count }.by(1)
    end

    it "adds a util server" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "util",
          :flavor_id   => "m3.large",
          :name        => "resque",
        ).resource!
      }.to change { environment.servers.count }.by(1)
    end

    it "does not add a util server without a name" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "util",
          :flavor_id   => "m3.large",
        ).resource!
      }.to raise_error(Ey::Core::Response::BadRequest, /value is empty: name/)
    end

    it "adds a db slave" do
      expect {
        client.servers.create!(
          :environment => environment,
          :role        => "db_slave",
          :flavor_id   => "m3.large",
        ).resource!
      }.to change { environment.servers.count }.by(1)
    end
  end
end
