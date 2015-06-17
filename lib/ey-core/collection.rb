class Ey::Core::Collection < Cistern::Collection
  class << self
    attr_accessor :model_root, :model_request, :collection_root, :collection_request
  end

  attribute :next_link
  attribute :prev_link
  attribute :last_link
  attribute :total_count, type: :integer
  attribute :url

  def create!(*args)
    model = self.new(*args)
    model.save!
  end

  def model_root
    self.class.model_root
  end

  def model_request
    self.class.model_request
  end

  def perform_get(params)
    connection.send(self.model_request, params).body[self.model_root]
  end

  def get!(id)
    if data = perform_get("id" => id)
      new(data)
    else
      nil
    end
  end

  def get(id)
    get!(id)
  rescue Ey::Core::Response::NotFound
    nil
  end

  def collection_root
    self.class.instance_variable_get(:@collection_root)
  end

  def collection_request
    self.class.instance_variable_get(:@collection_request)
  end

  def next_page
    new_page.all("url" => self.next_link) if self.next_link
  end

  def previous_page
    new_page.all("url" => self.prev_link) if self.prev_link
  end

  def last_page
    all("url" => self.last_link)
  end

  def ==(comparison_object)
    comparison_object.equal?(self) ||
      (comparison_object.is_a?(self.class) &&
       comparison_object.map(&:identity) == self.map(&:identity))
  end

  def all(params={})
    params["url"] ||= self.url

    self.load(
      self.connection.send(self.collection_request, Cistern::Hash.stringify_keys(params))
    )
  end

  def first(params={})
    params.empty? ? super() : all(params).to_a.first
  end

  # asserts the results contain only a single record and returns it
  def one
    if size == 0
      raise "Could not find any records"
    elsif size > 1
      raise "Search returned multiple records when only one was expected"
    else
      first
    end
  end

  def each_page
    return to_enum(:each_page) unless block_given?
    page = self
    while page
      yield page
      page = page.next_page
    end
  end

  def each_entry
    return to_enum(:each_entry) unless block_given?
    page = self
    while page
      page.to_a.each { |r| yield r }
      page = page.next_page
    end
  end

  def page_parameters(response)
    links = (response.headers['Link'] || "").split(", ").inject({}) do |r, link|
      value, key = link.match(/<(.*)>; rel="(\w+)"/).captures
      r.merge("#{key}_link" => value)
    end

    links.merge(total_count: response.headers['X-Total-Count'])
  end

  def new_page
    self.class.new(connection: self.connection)
  end

  def load(data)
    if data.is_a?(Ey::Core::Response)
      self.merge_attributes(page_parameters(data))
      super(data.body[self.collection_root])
    else
      super
    end
  end
end
