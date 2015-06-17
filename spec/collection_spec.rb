require 'spec_helper'

describe "Ey::Core::Collection" do
  let!(:client) { create_client(user: create_user) }

  context "with some accounts" do
    before(:each) { 50.times { create_account(client: client) } }

    describe "#total_count" do
      it "can get the total item count" do
        expect(client.accounts.all.total_count).to eq(50)
      end
    end

    describe "#first" do
      it "can get the first item" do
        account = client.accounts.all[1]

        expect(client.accounts.first(name: account.name)).to eq(account)
      end
    end

    describe "#each_page" do
      it "should yield multiple pages" do
        count = 0

        client.accounts.all.each_page { |_| count += 1 }

        expect(count).to eq(3)
      end
    end

    describe "#each_entry" do
      it "should yield multiple entries" do
        count = 0

        client.accounts.all.each_entry { |*| count += 1 }

        expect(count).to eq(50)
      end
    end
  end
end
