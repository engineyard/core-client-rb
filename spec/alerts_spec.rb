require 'spec_helper'

describe 'alerts' do
  let(:client) { create_client }
  let(:alert_params) { {
    :message     => Faker::Lorem.sentence(1),
    :description => Faker::Hacker.verb,
    :severity    => "warning",
    :name        => Faker::Hacker.noun,
    :external_id => SecureRandom.uuid,
  } }

  it 'should fail to create an alert with no resource' do
    expect { client.alerts.create!(alert_params) }.to raise_error Ey::Core::Response::Unprocessable
  end

  context 'with a database server' do
    let(:database_server) { create_database_service(client: client).servers.first }

    it 'should create an alert' do
      alert = nil
      expect {
        alert = database_server.alerts.create!(alert_params)
      }.to change  { client.alerts.size          }.by(1).
        and change { database_server.alerts.size }.by(1)

      expect(alert.database_server).to eq(database_server)
      expect(alert.resource).to        eq(database_server)

      expect(alert.description).to     eq(alert_params[:description])
      expect(alert.external_id).to     eq(alert_params[:external_id])
      expect(alert.finished_at).to     eq(nil)
      expect(alert.message).to         eq(alert_params[:message])
      expect(alert.name).to            eq(alert_params[:name])
      expect(alert.severity).to        eq(alert_params[:severity])

      alert.reload

      expect(alert.database_server).to eq(database_server)
      expect(alert.resource).to        eq(database_server)

      expect(alert.description).to     eq(alert_params[:description])
      expect(alert.external_id).to     eq(alert_params[:external_id])
      expect(alert.finished_at).to     eq(nil)
      expect(alert.message).to         eq(alert_params[:message])
      expect(alert.name).to            eq(alert_params[:name])
      expect(alert.severity).to        eq(alert_params[:severity])
    end
  end

  context 'with a server' do
    let!(:account)     { create_account(client: client) }
    let!(:provider)    { create_provider(account: account) }
    let!(:environment) { create_environment(account: account, name: Faker::Name.first_name) }

    it 'should create an alert' do
      server = client.servers.all.first
      alert  = nil

      expect {
        alert = server.alerts.create!(alert_params)
      }.to change  { client.alerts.size }.by(1).
        and change { server.alerts.size }.by(1)

      expect(alert.message).to     eq(alert_params[:message])
      expect(alert.description).to eq(alert_params[:description])
      expect(alert.severity).to    eq(alert_params[:severity])
      expect(alert.name).to        eq(alert_params[:name])
      expect(alert.external_id).to eq(alert_params[:external_id])
      expect(alert.started_at).to  be_nil
      expect(alert.server).to      eq(server)

      alert.reload

      expect(alert.message).to     eq(alert_params[:message])
      expect(alert.description).to eq(alert_params[:description])
      expect(alert.severity).to    eq(alert_params[:severity])
      expect(alert.name).to        eq(alert_params[:name])
      expect(alert.external_id).to eq(alert_params[:external_id])
      expect(alert.started_at).to  be_nil
      expect(alert.server).to      eq(server)
    end

    it "create an alert that has been started" do
      server = client.servers.all.first
      alert = nil

      expect {
        alert = server.alerts.create!(alert_params.merge(started_at: Time.now))
      }.to change { server.alerts.size }.by(1)

      expect(alert.started_at).not_to be_nil
      expect(alert.reload.started_at).not_to be_nil
    end
  end

  context "given some alerts" do
    let(:database_server)  { create_database_service(client: client).servers.first }
    let(:database_server2) { create_database_service(client: client).servers.first }

    let!(:alerts) {
      [
        client.alerts.create!(
          :database_server => database_server,
          :message         => Faker::Lorem.sentence(1),
          :description     => Faker::Hacker.verb,
          :severity        => "warning",
          :name            => Faker::Hacker.noun,
          :external_id     => SecureRandom.uuid,
        ),
        client.alerts.create!(
          :database_server => database_server2,
          :message         => Faker::Lorem.sentence(1),
          :description     => Faker::Hacker.verb,
          :severity        => "warning",
          :name            => Faker::Hacker.noun,
          :external_id     => SecureRandom.uuid,
        ),
      ]
    }

    it "should list alerts" do
      expect(
        client.alerts.all
      ).to match_array(alerts)
    end

    it "should filter alerts" do
      expect(database_server.alerts.all).to match_array(alerts[0])
      expect(client.alerts.all(database_server: database_server.identity)).to match_array(alerts[0])

      expect(database_server2.alerts.all).to match_array(alerts[1])
      expect(client.alerts.all(database_server: database_server2.identity)).to match_array(alerts[1])
    end

    it "should update alert" do
      alert = alerts.first
      expect { alert.update(acknowledged: true) }.to change { alert.acknowledged }.from(false).to(true)
      expect { alert.update(message: "something else") }.to change { alert.reload.message }
      expect { alert.update(external_id: "new-id") }.to change { alert.reload.external_id }
      expect { alert.update(started_at: Time.now) }.to change { alert.reload.started_at }.from(nil)
      expect {
        alert.update(finished_at: Time.now)
      }.to  change { alert.reload.finished_at }.from(nil).
        and change { database_server.alerts.all.size }.by(-1)
    end
  end
end
