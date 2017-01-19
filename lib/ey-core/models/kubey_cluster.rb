class Ey::Core::Client::KubeyCluster < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :client_certificate
  attribute :client_key
  attribute :certificate_authority
  attribute :cluster_public_hostname

  has_one :environment

  def kube_config(name)
    {
      'apiVersion' => 'v1',
      'kind' => 'Config',
      'preferences' => {},
      'current-context' => name,
      'users' => [
        'name' => name,
        'user' => {
          'client-certificate-data' => encode(self.client_certificate),
          'client-key-data' => encode(self.client_key),
        },
      ],
      'contexts' => [
        'name' => name,
        'context' => {
          'user' => name,
          'cluster' => name,
        },
      ],
      'clusters' => [
        'name' => name,
        'cluster' => {
          'server' => "https://#{self.cluster_public_hostname}",
          'certificate-authority-data' => encode(self.certificate_authority),
        },
      ],
    }
  end

  private

  def encode(str)
    Base64.encode64(str).gsub("\n","")
  end

end
