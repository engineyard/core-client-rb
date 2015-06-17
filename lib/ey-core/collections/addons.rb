class Ey::Core::Client::Addons < Ey::Core::Collection
  model Ey::Core::Client::Addon

  self.model_root         = "addon"
  self.model_request      = :get_addon
  self.collection_root    = "addons"
  self.collection_request = :get_addons

  def perform_get(params)
    id = params.delete("id") or raise "ID needed"
    url = "#{self.url}/#{id}"
    params['url'] = url
    super(params)
  end

end
