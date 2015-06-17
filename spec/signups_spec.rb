require 'spec_helper'

describe 'signups' do
  context "with a hmac client" do
    let!(:hmac_client) { create_hmac_client }

    it "should create a user and account" do
      signup_params = {
        :name         => Faker::Name.name,
        :email        => Faker::Internet.email,
        :password     => SecureRandom.hex(8),
        :account_name => SecureRandom.hex(6),
        :signup_via   => "deis",
      }

      signup = hmac_client.signups.create!(signup_params)

      expect(signup.user.name).to eq(signup_params[:name])
      expect(signup.user.email).to eq(signup_params[:email])
      expect(signup.account.name).to eq(signup_params[:account_name])
      expect(signup.user.accounts).to contain_exactly(signup.account)

      # foyer only
      # expect(signup.account.signup_via).to eq(signup_params[:signup_via])
    end
  end
end
