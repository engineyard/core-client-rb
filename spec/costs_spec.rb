require 'spec_helper'

describe 'Costs' do
  let(:client)   { create_client }
  let!(:account) { create_account(client: client) }

  it 'should get costs for an account' do
    create_cost(client, account: account)
    expect(account.costs.all).not_to be_empty
  end
end
