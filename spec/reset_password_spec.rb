require 'spec_helper'

describe 'reset_password' do
  context "with an HMAC client" do
    let!(:client) { create_hmac_client }

    it "should create a password reset request" do
      email = create_user.email

      password_reset = client.reset_password(email: email, redirect_uri: "http://example.com").body["password_reset"]

      expect(password_reset).to eq("sent" => true)
    end
  end
end

