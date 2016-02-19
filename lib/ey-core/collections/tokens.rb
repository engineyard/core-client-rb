class Ey::Core::Client::Tokens < Ey::Core::Collection

  model Ey::Core::Client::Token

  self.model_root         = "token"
  self.model_request      = :get_token
  self.collection_root    = "tokens"
  self.collection_request = :get_tokens
end
