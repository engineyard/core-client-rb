class Ey::Core::Client
  class Real
    def get_addon_attachment(params={})
      url   = params.delete("url") or raise "URL needed"
      request(
        :params => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_addon_attachment(params={})
      extract_url_params!(params)

      account = find(:accounts, params["account"])
      addon   = find(:addons, params["addon"])

      attachment_id = resource_identity(params["attachment"])

      found_attachments = load_addon_attachments(account["id"], addon["name"])

      if attachment = found_attachments.find{|attachment| attachment['id'] == attachment_id}
        response(
          :body    => {"addon_attachment" => attachment},
          :status  => 200,
        )
      else
        response(status: 400)
      end
    end
  end # Mock
end
