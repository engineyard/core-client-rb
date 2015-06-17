
require 'spec_helper'

RSpec.describe Ey::Core::Client do
  let!(:client)   { create_client }
  let!(:account)  { create_account }
  let!(:cluster)  { create_cluster(account: account, client: client, provider: provider) }
  let!(:provider) { create_provider(account: account, client: client) }
  let!(:user)     { create_user }

  before {
    cluster.slots.create(quantity: 2)
    cluster.cluster_updates.create!.ready!
  }

  it "should list unfinished requests" do
    expect(client.requests.all(finished_at: nil)).to be_empty

    request = cluster.cluster_updates.create!

    expect(client.requests.all(finished_at: nil)).to contain_exactly(request)
  end
end
