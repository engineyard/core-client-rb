require 'spec_helper'

describe 'as a user' do
  let!(:client)   { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }
  let!(:application) { create_application(account: account) }
  let!(:environment) { create_environment(account: account, application: application) }

  it "creates a cdn distribution" do
    req = client.cdn_distributions.create!(provider: provider,
                                           application: application,
                                           environment: environment)

    cdn_distribution = req.resource!

    expect(cdn_distribution.provider).to     eq(provider)
    expect(cdn_distribution.application).to  eq(application)
    expect(cdn_distribution.environment).to  eq(environment)
    expect(cdn_distribution.domain).to_not   be_nil
    expect(cdn_distribution.origin).to_not   be_nil
  end

  context "with a cdn distribution" do
    let!(:cdn_distribution) { client.cdn_distributions.create!(provider: provider, application: application, environment: environment).resource! }

    it "destroys a cdn distribution" do
      expect { cdn_distribution.destroy }.to change { client.cdn_distributions.all.size }.by(-1)
      expect(cdn_distribution.reload.deleted_at).not_to be_nil
    end

    it "updates a cdn distribution" do
      cdn_distribution.aliases         = ["one", "two", "three"]
      cdn_distribution.asset_host_name = "whatever.com"
      cdn_distribution.save.resource!
      expect(cdn_distribution.aliases).to include("one", "two", "three")
      expect(cdn_distribution.asset_host_name).to eq("whatever.com")
    end
  end
end
