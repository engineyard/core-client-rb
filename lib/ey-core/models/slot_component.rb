class Ey::Core::Client::SlotComponent < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :configuration
  attribute :created_at, type: :time
  attribute :deleted_at, type: :time
  attribute :name
  attribute :updated_at, type: :time

  has_one :slot
  has_one :cluster_component
  has_one :component

  def save!
    raise "Cannot create new slot components" if new_record?

    params = {
      "id" => id,
      "slot_component" => {
        "configuration" => configuration,
      }
    }

    merge_attributes(self.connection.update_slot_component(params).body["slot_component"])
  end
end
