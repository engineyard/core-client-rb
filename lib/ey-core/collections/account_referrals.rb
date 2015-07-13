class Ey::Core::Client::AccountReferrals < Ey::Core::Collection
  model Ey::Core::Client::AccountReferral

  self.model_root         = 'account_referral'
  self.model_request      = 'get_account_referral'
  self.collection_root    = 'account_referrals'
  self.collection_request = 'get_account_referrals'

  attribute :referrer_account_id
end
