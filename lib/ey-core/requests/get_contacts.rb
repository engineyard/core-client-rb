class Ey::Core::Client
  class Real
    def get_contacts(params={})
      request(
        :params => params,
        :query  => Ey::Core.paging_parameters(params),
        :path   => "/contacts",
        :url    => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def get_contacts(params={})
      extract_url_params!(params)

      resources = if database_service_url = params.delete("database_service")
                    database_service_id = resource_identity(database_service_url)
                    contact_ids = self.data[:contact_assignments].inject([]) { |r, (contact_id, resource_id)| (resource_id == database_service_id) ? r << contact_id : r }
                    self.data[:contacts].select { |id, _| contact_ids.include?(id) }
                  else
                    self.data[:contacts]
                  end

      headers, contacts_page = search_and_page(params, :contacts, search_keys: %w[name email], resources: resources)

      response(
        :body    => {"contacts" => contacts_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
