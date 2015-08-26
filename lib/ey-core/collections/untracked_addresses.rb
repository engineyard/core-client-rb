class Ey::Core::Client::UntrackedAddresses < Ey::Core::Collection
  model Ey::Core::Client::UntrackedAddress
  self.model_root         = "untracked_address"
end
