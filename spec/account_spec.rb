require 'spec_helper'

describe 'accounts' do
  let(:client) {create_client}

  let(:account) {
    create_account(
      client: client, creator: client,
      account: {
        owner: create_user(client: client, creator: client)
      }.merge(details)
    )
  }

  describe '#type' do
    let(:details) {{type: 'oracle'}}

    it 'is the account type for the account' do
      expect(account.type).to eql('oracle')
    end
  end

  describe '#signup_via' do
    let(:details) {{signup_via: 'deis'}}

    it 'is the service through which the owner signed up' do
      expect(account.signup_via).to eql('deis')
    end
  end

  describe '#legacy_id' do
    let(:details) {{}}

    # Fun fact: we're not allowed to set legacy_id in create_account
    before(:each) do
      client.data[:accounts][account.id].merge!(
        {'legacy_id' => '19283'}
      )

      account.reload
    end

    it 'is the legacy_id for the account' do
      expect(account.legacy_id).to eql('19283')
    end
  end

  context 'when searched by legacy_id' do
    let(:details) {{}}
    let(:legacy_id) {Cistern::Mock.random_numbers(6)}
    let(:searched) {client.accounts.all(legacy_id: legacy_id)}

    before(:each) do
      client.data[:accounts][account.id].merge!(
        {'legacy_id' => legacy_id}
      )

      account.reload
    end

    it 'is a resounding success', mock_only: true do
      expect(searched).to include(account)
    end
  end
end
