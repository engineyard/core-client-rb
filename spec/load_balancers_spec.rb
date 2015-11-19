require 'spec_helper'

describe 'as a user' do
  let!(:client)   { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it "creates a load balancer" do
    name = Faker::Name.first_name
    location = "us-east-1"

    req = client.load_balancers.create!(provider: provider,
                                        name: name,
                                        location: location)

    load_balancer = req.resource!

    expect(load_balancer.name).to     eq(name)
    expect(load_balancer.location).to eq(location)
    expect(load_balancer.provider).to eq(provider)
  end

  context "with a load balancer" do
    let!(:load_balancer) { client.load_balancers.create!(provider: provider, name: Faker::Name.first_name, location: "us-east-1").resource! }

    it "destroys a load balancer" do
      expect { load_balancer.destroy }.to change { client.load_balancers.all.size }.by(-1)
      expect(load_balancer.reload.deleted_at).not_to be_nil
    end
  end
end
