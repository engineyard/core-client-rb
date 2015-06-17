class Ey::Core::Client::Users < Ey::Core::Collection
  model Ey::Core::Client::User

  self.model_root         = "user"
  self.model_request      = :get_user
  self.collection_root    = "users"
  self.collection_request = :get_users

  def current
    new(connection.get_current_user.body["user"])
  end
end
