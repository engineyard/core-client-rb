class Ey::Core::Client::Providers < Ey::Core::Collection

  model Ey::Core::Client::Provider

  self.model_root         = "provider"
  self.model_request      = :get_provider
  self.collection_root    = "providers"
  self.collection_request = :get_providers

  def create!(params)
    params[:collection_url] = self.url
    super(params)
  end

end
