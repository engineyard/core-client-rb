require 'spec_helper'

describe 'signups' do
  context "with a hmac client" do
    let!(:client) { create_hmac_client }

    it "should create a user and account" do
      user_params = {
        :name         => Faker::Name.name,
        :email        => Faker::Internet.email,
        :password     => SecureRandom.hex(8),
      }
      account_params = {
        :account_name => SecureRandom.hex(6),
        :signup_via   => "deis",
      }

      signup = client.signup(user_params, account_params).body["signup"]
      binding.pry
    end
  end
end
