require 'spec_helper'

describe 'tokens' do
  context "with a hmac client" do
    let!(:client) { create_client }

    context "with a user" do
      let!(:user) { client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }

      it "should generate a token" do
        token = client.tokens.create!(on_behalf_of: user)
        expect(token.auth_id).not_to be_nil
      end

      # other endpoint: upgrade, which takes a limited token and upgrades to full_access.

    end
  end
end
