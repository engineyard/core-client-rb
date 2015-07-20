require 'spec_helper'

describe 'Costs' do
  let(:client)   { create_client }
  let!(:account) { create_account(client: client) }

  it 'should return an empty array with no costs' do
    expect(account.costs.all).to be_empty
  end

  it 'should get costs for an account' do
    create_cost(client, account: account)
    expect(account.costs.all).not_to be_empty
  end

  it 'should search costs' do
    create_cost(client, account: account, level: 'total')
    create_cost(client, account: account, level: 'summarized')
    costs = account.costs.select { |c| c.level == 'total' }
    expect(costs.first.level).to eq 'total'
  end
end
