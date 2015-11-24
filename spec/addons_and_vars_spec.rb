require 'spec_helper'

describe 'addons' do
  let!(:client) { create_client }

  context "with user and account" do
    let!(:account) { create_account(client: client) }

    it "list addons" do
      expect(account.addons.all).to be_empty
    end

    describe "create addon" do
      before do
        @addon = account.addons.create!(
          :name => "fooooo",
          :sso_url => "http://example.com",
          :vars => {foo: "bar", baz: "bob"})
      end

      it "creates the addon" do
        expect(@addon.name).to eq "fooooo"
        expect(@addon.sso_url).to eq "http://example.com"
        expect(@addon.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      it "shows in the list" do
        expect(account.addons.all.size).to eq 1
        addon = account.addons.first
        expect(addon.name).to eq "fooooo"
        expect(addon.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      it "can be fetched" do
        addon_refetched = account.addons.get(@addon.id)
        expect(addon_refetched.id).to eq @addon.id
        expect(addon_refetched.name).to eq "fooooo"
        expect(addon_refetched.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      #Effectively also tests that the resource_url is set in all the ways an addon can be fetched
      it "can be updated (3 ways)" do
        tryit = Proc.new do |add, name, vars|
          add.name = name
          add.vars = vars
          add.save!
          add.reload
          expect(add.name).to eq name
          expect(add.vars).to eq vars
        end
        tryit.call(account.addons.get(@addon.id), "fetchedwithget", "fetchsingle" => "GET")
        tryit.call(account.addons.first, "fetchedfromlist", "fetchmulti" => "GET")
        tryit.call(@addon, "createresult", "created" => "POST")
      end

      it "can be destroyed" do
        @addon.destroy
        expect(account.addons.all.size).to eq 0
      end
    end
  end
end
