module Ey::Core::Mock
  module Searching
    def url_for_page(collection, page_index, page_size, rel)
      "<#{url_for(collection)}?page=#{page_index}&per_page=#{page_size}>; rel=\"#{rel}\""
    end

    def page(params, collection, options={})
      if params["url"]
        raise "url param should be extracted before paging"
      end

      unless resources = options.delete(:resources)
        raise "tried to `page` #{collection} without given `resources` option."
      end

      if options.any?
        raise ArgumentError, "Unknown options: #{options.keys}"
      end

      page_size   = (params["per_page"] || 20).to_i
      page_index  = (params["page"] || 1).to_i
      total_pages = (resources.size.to_f / page_size.to_f).ceil
      offset      = (page_index - 1) * page_size
      links       = []

      resource_page = resources.values.reverse.slice(offset, page_size)

      if page_index < total_pages
        links << url_for_page(collection, page_index + 1, page_size, 'next')
      end

      if page_index - 1 > 0
        links << url_for_page(collection, page_index - 1, page_size, 'prev')
      end

      links << url_for_page(collection, total_pages, page_size, 'last')
      headers = {
        "Link" => links.join(", "),
        "X-Total-Count" => resources.size
      }

      [headers, resource_page]
    end

    def pluralize(word)
      # @fixme make it better
      "#{word}s"
    end

    # Filter a mocked data collection by given search parameters
    # @param resource [...] mocked data collection to search through
    # @param params [Hash] parameters to AND search by, array value ORs within that key
    def search(resources, params)
      search_params = Cistern::Hash.stringify_keys(params)

      resources.select do |id, attrs|
        search_params.all? do |term, condition|
          if condition.kind_of? Array
            condition.include?(attrs[term]) || condition.include?(attrs["_#{term}"])
          else
            # @fixme the search functions should define more accurate / explicit definition of search terms
            # this is a cheap mapping

            # [provider, 3] => "http://api-test.engineyard.com/providers/3"
            resource_url = url_for("/#{pluralize(term.to_s).gsub("_", "-")}/#{condition}")
            hidden_term = "_#{term}"

            (
              attrs.key?(term) && (
                attrs[term] == resource_url ||  # find by relation to a specific resource
                attrs[term] == condition        # find by direct attribute
              )
            ) || (
              attrs.key?(hidden_term) &&
              (attrs[hidden_term] == condition) # find by a hidden attribute
            )
          end
        end
      end
    end

    # @param params [Hash] all query params
    # @param collection [Symbol] collection to use, matches self.data[...]
    # @option opts [Array<#to_s>] :search_keys param keys to search by, using ==
    # @option opts [...] :resources (self.data[collection]) to search and page from
    # @see #page for more options
    def search_and_page(params, collection, options={})
      deleted_key   = options.delete(:deleted_key) || "deleted_at"
      resources     = (options.delete(:resources) || self.data[collection]) or raise ArgumentError, "Could not find collection: #{collection}"
      search_keys   = options.delete(:search_keys) or raise ArgumentError, "Missing required option 'search_keys'"
      search_params = Cistern::Hash.slice(params, *search_keys)

      unless (bad_params = params.keys - search_keys - %w[deleted with_deleted page per_page]).empty?
        raise "Cannot search #{collection} by params: #{bad_params.join(', ')}"
      end

      @logger.debug('request.search') { "Searching #{collection} with: #{params.inspect}" }

      resources = search(resources, search_params)

      # filter out deleted resources by default
      filter = lambda { |_, attrs| attrs[deleted_key] }

      unless params["with_deleted"]
        params["deleted"] ? resources.select!(&filter) : resources.reject!(&filter)
      end

      page(params, collection, options.merge(resources: resources))
    end
  end
end
