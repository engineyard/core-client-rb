class Ey::Core::Client::Slots < Ey::Core::Collection

  model Ey::Core::Client::Slot

  self.model_root         = "slot"
  self.model_request      = :get_slot
  self.collection_root    = "slots"
  self.collection_request = :get_slots

  def create!(options={})
    response = connection.create_slots(
      "url"     => self.url,
      "cluster" => options[:cluster_id] || (options[:cluster] && options[:cluster].identity),
      "slots" => {
        "names"    => options[:names],
        "quantity" => options[:quantity],
        "flavor"   => options[:flavor],
        "image"    => options[:image],
      }.reject {|key,val| val.nil? }
    )
    connection.slots.load(response.body["slots"])
  end

  def create(options={})
    create!(options)
    self
  rescue Ey::Core::Response::Error
    false
  end
end
