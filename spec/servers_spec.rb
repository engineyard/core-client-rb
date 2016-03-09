require 'spec_helper'

describe 'servers' do
  let!(:client)      { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:application) { create_application(account: account) }
  context "with a solo environment" do

    let!(:environment) { create_environment(account: account, application: application, name: Faker::Name.first_name) }
    let!(:server)      { environment.servers.first }

    it "has an association with the environment" do
      expect(server.environment).to eq(environment)
    end

    it "reboots" do
      reboot_request = server.reboot
      reboot_request.ready!
      expect(reboot_request.successful).to be true
    end

    it "applies" do
      expect(server.apply.ready!).to be_successful

      if Ey::Core::Client.mocking?
        expect(client.data[:instance_updates].count).to eq(1)
      end
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
