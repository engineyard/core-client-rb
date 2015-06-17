class Ey::Core::Client::Backup < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :metadata
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :finished_at, type: :time

  has_one :cluster

  has_many :files, key: :backup_files

  def save!
    requires :collection

    params = {
      "url"    => self.collection.url,
      "backup" => {
        "metadata" => self.metadata,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_backup(params).body["backup"])
    else raise NotImplementedError # update
    end
  end

  def finish!
    requires :id

    merge_attributes(self.connection.finish_backup("id" => self.identity).body["backup"])
  end
end
