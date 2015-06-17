require 'spec_helper'

describe 'servers' do
  let(:client)       { create_client }
  let!(:hmac_client) { create_hmac_client }
  let!(:user)        { hmac_client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
  let!(:account)     { hmac_client.accounts.create!(owner: user, name: Faker::Name.name) }
  let!(:provider)    { account.providers.create!(type: "aws").resource! }

  context "with a server", :mock_only do
    let!(:environment) { account.environments.create(name: Faker::Name.name) }
    let!(:server) {
      create_server(hmac_client,
                    :environment    => environment,
                    :provider       => provider,
                    :provisioned_id => "i-a1000fce",
                    :state          => "running")
    }

    let!(:event) { create_server_event(hmac_client, type: "member-failed", server: server) }

    before(:each) do
      another_server = create_server(hmac_client,
                                     :environment => environment,
                                     :provider => provider,
                                     :provisioned_id => "i-a1000fce",
                                     :state => "running")

      create_server_event(hmac_client,
                          :type   => "member-failed",
                          :server => another_server)
    end

    it "should list server events" do
      expect(server.events.to_a).to eq([event])
    end
  end
end
