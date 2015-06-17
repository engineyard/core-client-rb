require 'spec_helper'

describe 'tokens' do
  context "with a hmac client" do
    let!(:hmac_client) { create_hmac_client }

    context "with a user" do
      let!(:user)         { hmac_client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
      let!(:redirect_url) { "http://redirect.example.com" }

      it "should generate a session token" do
        session_token = hmac_client.session_tokens.create!(on_behalf_of: user, redirect_url: redirect_url)

        expect(session_token.on_behalf_of).to eq(user.id)
        expect(session_token.redirect_url).to eq(redirect_url)
        expect(session_token.expires_at).not_to be_nil
        expect(session_token.upgrade_url).not_to be_nil
      end
    end
  end
end

