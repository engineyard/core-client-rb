require 'spec_helper'

describe 'logs', :mock_only  do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
  let!(:cluster)     { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }

  let(:server_client) { create_server_client(client.servers.all.first) }

  before do
    cluster.slots.create(quantity: 1)
    cluster.cluster_updates.create!.ready!
  end

  describe "create log" do
    it "can upload a file" do
      log = server_client.logs.create!(
        :component_action_id => "123",
        :file                => "{}",
        :filename            => "blah.json",
        :mime_type           => "application/json"
      )
      expect(log.id).to be
      expect(log.download_url).to be
      expect(log.filename).to eq("blah.json")
    end

    it "can create a log using body content" do
      body = "{}"
      log = server_client.logs.create!(
        :body                => body,
        :component_action_id => "123",
        :mime_type           => "application/json",
      )
      expect(log.id).to be
      expect(log.filename).to be
      expect(log.download_url).to be
    end
  end

  it "can fetch a log" do
    created_log = server_client.logs.create!(
      :component_action_id => "123",
      :file                => "{}",
      :mime_type           => "application/json"
    )
    expect(client.logs.get!(created_log.id)).to eq(created_log)
  end
end
