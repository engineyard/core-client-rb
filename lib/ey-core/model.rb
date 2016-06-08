class Ey::Core::Model < Cistern::Model
  def url
    if self.class.attributes[:url]
      read_attribute(:url)
    else
      "#{self.collection.url}/#{self.id}"
    end
  end

  def to_s
    shortname = self.class.name.split("::").last
    "#{shortname}:#{id}"
  end

  def self.range_parser(v)
    case v
    when Range then
      v
    when String then
      first, last = v.split("-").map(&:to_i)
      last ||= first
      Range.new(first, last)
    else
      v
    end
  end

  def update!(attributes)
    merge_attributes(attributes)
    save!
  end

  def save
    save!
  rescue Ey::Core::Response::Error
    false
  end

  def destroy
    destroy!
  rescue Ey::Core::Response::Error
    false
  end
end
