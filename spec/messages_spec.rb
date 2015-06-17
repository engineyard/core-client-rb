require 'spec_helper'

describe 'messages' do
  let(:client)    { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  context "with a provision address request" do
    before(:each) do
      @request = client.addresses.create!(provider: provider, location: "us-west-2")
    end

    let(:request) { @request }

    it "should create a message for the address" do
      message = client.messages.create!(message: "hi der", request_id: request.id)

      expect(client.messages.get!(message.identity)).to eq(message)
    end

    it "should require collection url to create a message" do
      expect {
        client.messages.create!(message: "ohai")
      }.to raise_error(ArgumentError, /missing.*url/)
    end
  end
end
