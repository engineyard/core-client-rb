require 'spec_helper'

describe 'storages' do
  let!(:client) { create_client }
  let!(:account) { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it "should create a storage" do
    storage_request = provider.storages.create!(name: SecureRandom.hex(6), location: "us-east-1", provider: provider)
    storage_request.ready!
    expect(storage_request.successful).to be_truthy
  end

  describe "with a storage" do
    let!(:storage) { provider.storages.create!(name: SecureRandom.hex(6), location: "us-east-1", provider: provider).resource! }

    it "should list storages" do
      expect(client.storages).to include(storage)
    end

    it "should get a storage" do
      expect(client.storages.get(storage.identity)).to eq(storage)
    end

    it "should destroy a storage" do
      destroy_request = storage.destroy!
      destroy_request.ready!
      expect(destroy_request.successful).to be(true)
    end

    describe "users" do
      it "should create a new storage user" do
        request = storage.storage_users.create!(username: SecureRandom.hex(6), storage: storage, permissions: "admin")
        request.ready!
        expect(request.successful).to be(true)
      end

      describe "with a user" do
        let!(:user) { storage.storage_users.create!(username: SecureRandom.hex(6), storage: storage, permissions: "admin").resource! }

        it "should list storage users" do
          expect(storage.storage_users).to include(user)
        end

        it "should get a storage user" do
          expect(storage.storage_users.get(user.id)).to eq(user)
        end

        it "should destroy a storage user" do
          request = user.destroy!
          request.ready!
          expect(request.successful).to be(true)
        end
      end
    end
  end
end
