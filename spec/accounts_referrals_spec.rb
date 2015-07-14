require 'spec_helper'

describe 'account_referrals' do
  let(:client) { create_client }
  let!(:referrer) { create_account(client: client) }

  it 'shows referrals for an account', :mock_only do
    referral = create_account_referral(client, referrer: referrer)

    expect(referrer.referrals.all).to contain_exactly(referral)
  end

  it 'shows all account referrals', :mock_only do
    referral1 = create_account_referral(client)
    referral2 = create_account_referral(client)
    account_referrals = client.account_referrals.all

    expect(account_referrals.map(&:identity)).to contain_exactly(referral1.id, referral2.id)
  end
end
