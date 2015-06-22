require 'spec_helper'

describe 'signups' do
  context "with a hmac client" do
    let!(:client) { create_hmac_client }

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

    it "should create a user and account" do
      user_params = {
        :name         => Faker::Name.name,
        :email        => Faker::Internet.email,
        :password     => SecureRandom.hex(8),
      }
      account_params = {
        :account_name => SecureRandom.hex(6),
      }
      features = [ public_feature.id ]

      signup = client.signup(user: user_params, account: account_params, features: features, redirect_url: "http://redirect.example.com").body["signup"]
      user = client.users.get(signup["user_id"])
      account = client.accounts.get(signup["account_id"])

      expect(user.name).to eq(user_params[:name])
      expect(user.email).to eq(user_params[:email])

      expect(account.name).to eq(account_params[:name])

      expect(user.accounts).to contain_exactly(account)
      expect(account.features.map(&:id)).to include(*features)

      expect(signup["upgrade_url"]).not_to be_nil
    end
  end
end
