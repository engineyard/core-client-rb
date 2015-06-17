require 'spec_helper'

describe 'as a user' do
  let!(:client) { create_client }

  let!(:public_feature) do
    if Ey::Core::Client.mocking?
      client.create_feature(
                     :id      => "public_feature",
                     :privacy => "public",
                     :name    => "A Public Feature",
                    )
    else
      client.features.all.first
    end
  end

  let!(:other_feature)  do
    if Ey::Core::Client.mocking?
      client.create_feature(
                     :id      => "other_feature",
                     :privacy => "private",
                     :name    => "Another Feature",
                    )
    else
      client.features.all.last
    end
  end

  context "with an account" do
    let!(:account) { create_account(client: client) }

    it "should list account features" do
      client.features.get(other_feature.identity).enable!(account)

      expect(account.features.all.size).to be > 0

      feature = account.features.first(id: other_feature.id)

      expect(feature.id).to          eq(other_feature.id)
      expect(feature.name).to        eq(other_feature.name)
      expect(feature.description).to eq(other_feature.description)
    end

    it "should enable feature" do
      expect {
        client.features.first.enable!(account)
      }.to change { account.features.all.size }.by(1)
    end

    it "should disable feature" do
      client.features.first.enable!(account)
      expect {
        client.features.first.disable!(account)
      }.to change { account.features.all.size }.by(-1)
    end
  end

  context "without an account" do
    it "should list features" do
      expect(client.features.all).to include(public_feature)
    end

    it "should show a feature" do
      feature = client.features.get(public_feature.identity)

      expect(feature).not_to be_nil

      expect(feature.id).to          eq(public_feature.identity)
      expect(feature.name).to        eq(public_feature.name)
      expect(feature.description).to eq(public_feature.description)
    end
  end

  context "with multiple accounts" do
    it "should list all enabled features"
    it "should list an account's enabled features"
  end
end
