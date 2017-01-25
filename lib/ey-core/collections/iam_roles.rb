class Ey::Core::Client::IamRoles < Ey::Core::Collection
  model Ey::Core::Client::IamRole

  self.model_root         = "iam_role"
  self.model_request      = :get_iam_role
  self.collection_root    = "iam_roles"
  self.collection_request = :get_iam_roles
end
