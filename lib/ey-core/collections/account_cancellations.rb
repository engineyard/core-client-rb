class Ey::Core::Client::AccountCancellations < Ey::Core::Collection
  model Ey::Core::Client::AccountCancellation

  self.model_root    = "account_cancellation"
  self.model_request = :get_account_cancellation
end
