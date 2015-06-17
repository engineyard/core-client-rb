require 'spec_helper'

describe 'users' do
  context "with an HMAC client" do
    let!(:client) { create_hmac_client }

    it "should create a user" do
      name  = Faker::Name.name
      email = Faker::Internet.email

      user = client.users.create!(name: name, email: email)
      user.name = name
      user.email = email
      expect(user.identity).not_to be_nil
      expect(user.staff).to be_falsy
      expect(user.password).to be_nil

      expect(user.accounts).to be_empty

      refetched = client.users.get(user.id)
      expect(refetched.name).to eq name
      expect(refetched.staff).to be_falsey

      if Ey::Core::Client.mocking?
        #Can't actually set users as staff in real core API, but apps that use core API may need to test behavior based on a user being staff
        client.find(:users, user.id).merge!(:staff => true)
        refetched_again = client.users.get(user.id)
        expect(refetched_again.staff).to be true
      end
    end

    context 'when email address is not available' do
      it 'should raise an error' do
        name  = Faker::Name.name
        email = Faker::Internet.email

        client.users.create!(name: name, email: email)

        expect {
          client.users.create!(name: name, email: email)
        }.to raise_exception(Ey::Core::Response::Unprocessable, /Email has already been taken/)
      end
    end
  end

  context "with a token client" do
    let(:client) { create_client }

    it "should not create a user" do
      expect {
        client.users.create!(name: Faker::Name.name, email: Faker::Internet.email)
      }.to raise_exception(Ey::Core::Response::Error)
    end

    it "should get current user" do
      expect(client.users.current).to be_a(Ey::Core::Client::User)

      if Ey::Core::Client.mocking?
        expect(client.users.current.id).to eq(client.current_user["id"])
      end
    end

    it "should destroy a user" do
      name  = Faker::Name.name
      email = Faker::Internet.email

      user = create_hmac_client.users.create!(name: name, email: email)
      user = client.users.get(user.identity)
      expect(user.deleted_at).to be_nil

      expect {
        user.destroy
      }.to change {client.users.all.size}.by(-1)

      expect(user.reload.deleted_at).not_to be_nil

      expect(client.users.all).not_to include(user)
      expect(client.users.all(deleted: true)).to include(user)
      expect(client.users.all(with_deleted: true)).to include(user)
    end
  end
end
