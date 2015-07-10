require 'spec_helper'

describe 'account_referrals' do
  let(:client) { create_client }
  let!(:referrer) { create_account(client: client) }

  it 'should search by referrer account id' do
    account_referrals = client.account_referrals.all(referrer_account_id: referrer.id)
    expect(account_referrals).not_to be nil
  end
end
