require 'spec_helper'

describe "reset_password" do
  context "with an HMAC client" do
    let!(:client) { create_hmac_client }

    it "should create a password reset request" do
      email = create_user.email

      password_reset = client.create_password_reset(email: email, redirect_uri: "http://example.com").body["password_reset"]

      expect(password_reset).to eq("sent" => true)
    end

    it "should reset a users password", :mock_only do
      password_reset = client.reset_password(reset_token: SecureRandom.hex(6), password: SecureRandom.hex(6)).body["password_reset"]

      expect(password_reset).to eq("accepted" => true)
    end
  end
end

