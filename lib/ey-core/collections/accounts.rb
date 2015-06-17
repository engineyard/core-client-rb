class Ey::Core::Client::Accounts < Ey::Core::Collection
  model Ey::Core::Client::Account

  self.model_root         = "account"
  self.model_request      = :get_account
  self.collection_root    = "accounts"
  self.collection_request = :get_accounts
end
