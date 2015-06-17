class Ey::Core::Client::AddonAttachments < Ey::Core::Collection

  model Ey::Core::Client::AddonAttachment

  self.model_root         = "addon_attachment"
  self.model_request      = :get_addon_attachment
  self.collection_root    = "addon_attachments"
  self.collection_request = :get_addon_attachments

  def perform_get(params)
    id = params.delete("id") or raise "ID needed"
    url = "#{self.url}/#{id}"
    params['url'] = url
    super(params)
  end

end
