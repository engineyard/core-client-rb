
require 'spec_helper'

RSpec.describe Ey::Core::Client do
  let!(:client)   { create_client }
  let!(:account)  { create_account }
  let!(:user)     { create_user }

  context "with a request" do
    let!(:request) { account.providers.create!(type: "aws") }

    it "should list unfinished requests" do
      expect(client.requests.all(finished_at: nil)).to contain_exactly(request)
    end

    it "request should finish after polling a number of times == Mock.delay" do
      Ey::Core::Client::Mock.delay = 3
      expect(client.requests.get(request.id).finished_at).to be_nil
      expect(client.requests.get(request.id).finished_at).to be_nil
      expect(client.requests.get(request.id).finished_at).to_not be_nil
    end
  end
end
