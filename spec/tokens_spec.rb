require 'spec_helper'

describe 'tokens' do
  context "with a hmac client" do
    let!(:client) { create_client }

    context "with a user" do
      let!(:user) { client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }

      it "generates a token" do
        token = client.tokens.create!(on_behalf_of: user)
        expect(token.auth_id).not_to be_nil
      end

      it "lists tokens" do
        tokens = user.tokens.all
        expect(tokens).not_to be_empty
      end

      it "gets a token" do
        token = user.tokens.first
        expect(token.reload).to be
      end

      context "with multiple users" do
        let!(:other_user) { client.users.create(name: Faker::Name.name, email: Faker::Internet.email) }

        it "only shows the correct tokens" do
          expect(user.tokens.all.count).to eq(1)
          expect(other_user.tokens.all.count).to eq(1)
          expect(user.tokens.first.on_behalf_of).to eq(client.url_for("/users/#{user.identity}"))
          expect(other_user.tokens.first.on_behalf_of).to eq(client.url_for("/users/#{other_user.identity}"))
        end
      end
    end
  end
end
