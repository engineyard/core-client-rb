require 'spec_helper'

describe 'as a user' do
  let(:client) { create_client }

  context "with an account", :mock_only do
    let!(:account)     { create_account(client: client) }
    let!(:provider)    { create_provider(account: account) }
    let!(:environment) { account.environments.create(name: Faker::Name.name) }
    let(:server)       { client.servers.first(provisioned_id: "i-a1000fce") }
    let(:legacy_alert)        { client.legacy_alerts.get(1001) }

    before do
      create_server(client, id: Cistern::Mock.random_numbers(6).to_i,
                     provisioned_id: "i-a1000fce",
                           provider: provider,
                        environment: environment,
                              state: "running")

      create_legacy_alert(client, id: 1001,
                              type: "cpu",
                          severity: "warning",
                            server: server,
                      acknowledged: false)
    end

    it "should fetch a legacy alert" do
      a = client.legacy_alerts.get(1001)

      expect(a).not_to be_nil
      expect(a.id).to          eq(1001)
      expect(a.type).to        eq("cpu")
      expect(a.severity).to    eq("warning")
      expect(a.acknowledged).to be false
      expect(a.server).to      eq(server)
    end

    it "should list legacy alerts" do
      legacy_alerts = client.legacy_alerts.all
      expect(legacy_alerts.size).to be(1)

      a = legacy_alerts.first
      expect(a.id).to          eq(1001)
      expect(a.type).to        eq("cpu")
      expect(a.severity).to    eq("warning")
      expect(a.acknowledged).to be false
      expect(a.server).to      eq(server)
    end
  end
end
