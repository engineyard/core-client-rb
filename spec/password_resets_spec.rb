require 'spec_helper'

describe 'password_resets' do
  context "with an HMAC client" do
    let!(:client) { create_hmac_client }

    it "should create a password reset request" do
      email = create_user.email

      password_reset = client.password_resets(email: email, redirect_uri: "http://example.com").body["password_reset"]

      expect(password_reset).to eq("sent" => true)
    end
  end
end

