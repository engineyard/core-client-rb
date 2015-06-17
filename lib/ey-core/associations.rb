module Ey::Core::Associations
  def assoc_coverage(options)
    if defined? Cistern::Coverage
      call = Cistern::Coverage.find_caller_before("ey-core/associations.rb")

      if call and call.label.start_with?("<class:")
        options[:coverage_file] = call.absolute_path
        options[:coverage_line] = call.lineno
        options[:coverage_hits] = 0
      end
    end
  end

  def associations
    @associations ||= {}
  end

  def assoc_reader(name, options={})
    assoc_key  = options[:key]        || "#{name}_id"
    collection = options[:collection] || "#{name}s"
    resource   = options[:resource]   || name
    assoc_name = options[:assoc_name] || resource

    # handle polymorphic assocations
    #
    # really only used for connector sources, as they may be cluster_components or addons
    disambiguate = Proc.new do |object, url, index=0|
      if object.is_a?(Array) && index > (object.size - 1)
        raise "No matching object found in #{object}"
      elsif object.is_a?(Array) && url
        url_pieces = URI.parse(url).path.split("/").map { |piece| piece.gsub(/-|_/,'') } # "/cluster-components/x" => ["clustercomponents", "x"]

        object.find do |model|
          normalized_model = model.to_s.gsub(/-|_/, '') # [:cluster_components, :addons] => ["clustercomponents", "addons"]
          url_pieces.find { |piece| piece.include?(normalized_model) }
        end
      elsif object.is_a?(Array)
        object[index]
      else
        object
      end
    end

    define_method(name) do
      url = self.send("#{name}_url")
      id  = send(assoc_key)

      if id || url
        begin
          index ||= 0
          this_resource   = disambiguate[resource, url, index]
          this_assoc_name = disambiguate[assoc_name, url, index]
          this_collection = disambiguate[collection, url, index]

          fetched = self.connection.send("get_#{this_assoc_name}", {"id" => id, "url" => url}).body
        rescue RuntimeError => e
          if e.message.match(/url needed/i)
            index += 1
            retry if index < 3
          else
            raise e
          end
        rescue Ey::Core::Response::NotFound
          index += 1
          index < 3 ? retry : raise
        end

        unless fetched[this_resource.to_s]
          raise "Expected a '#{this_resource.to_s}' in '#{fetched.inspect}'"
        end

        attributes = fetched[this_resource.to_s]

        if self.connection.respond_to?(this_collection)
          attributes = attributes.merge(collection: self.connection.send(this_collection))
        end

        self.connection.send(this_assoc_name, attributes)
      end
    end
  end

  def assoc_writer(name, options={})
    assoc_key = options[:key] || "#{name}_id"
    url_key   = options[:key] || "#{name}_url"

    attr_accessor assoc_key

    define_method("#{name}=") do |assoc|
      if assoc.respond_to?(:identity)
        self.send("#{assoc_key}=", assoc.identity)
      elsif assoc.is_a?(String) && assoc.match(URI::regexp)
        self.send("#{url_key}=", assoc)
      else
        self.send("#{assoc_key}=", assoc)
      end
    end
  end

  def assoc_accessor(name, options={})
    assoc_coverage(options)

    if self.associations[name]
      raise ArgumentError, "#{self.name} association[#{name}] specified more than once"
    else
      self.associations[name] = options
    end

    aliases = Array(options[:aliases] || name.to_s)

    attribute(:"#{name}_url", aliases: aliases, parser: lambda { |v,_| v.is_a?(String) && v })

    assoc_reader(name, options)
    assoc_writer(name, options)
  end

  alias has_one assoc_accessor

  def collection_reader(name, options={})
    assoc_coverage(options)

    if self.associations[name]
      raise ArgumentError, "#{self.name} association[#{name}] specified more than once"
    else
      self.associations[name] = options
    end

    attribute(:"#{name}_url", aliases: options[:aliases] || [name.to_s])

    assoc_key = options[:key] || name
    collection_key = options[:model] || assoc_key

    define_method(name) do
      value = self.send("#{name}_url")

      if self.identity && !value
        raise "Cannot load #{name} association: #{name}_url is not set"
      end

      # @fixme this allows collections to be stored in a url variable on create before being replaced
      # by a url entry after create upon {#merge_attributes}
      if value.nil?
        []
      elsif value.is_a?(String) && value.match(URI::regexp)
        self.connection.send(collection_key, {"url" => value})
      elsif value.is_a?(Hash)
        [value]
      else
        Array(value)
      end
    end
  end

  alias has_many collection_reader
end
