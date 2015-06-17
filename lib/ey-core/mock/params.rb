module Ey::Core::Mock
  module Params
    def url_params(url)
      uri   = URI.parse(url)
      query = uri.query || ""

      query.split("&").inject({}){|r,e| k,v = e.split("="); r.merge(k => v)}
    end

    def path_params(url)
      parts = URI.parse(url).path.split("/").rotate
      if parts.size % 2 == 1
        parts.pop
      end
      Hash[*parts].reject {|key,val| val.nil? || val.empty? }
    end

    def extract_url_params!(params)
      if url = params.delete("url")
        @logger.debug('request.params') { "Extracted params from url: #{path_params(url).inspect}" }

        path_params(url).each do |resource,id|
          next unless id && ! id.empty?
          params[resource.to_s.gsub(/s$/, '').gsub("-", "_")] = url_for("/#{resource}/#{id}")
        end

        params.merge!(url_params(url))
      end
    end
  end
end
