class Ey::Core::Client::DockerRegistryCredentials < Ey::Core::Model
  attribute :username
  attribute :password
  attribute :registry_endpoint
  attribute :expires_at, type: :time
end
