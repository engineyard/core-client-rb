class Ey::Core::Client::IamRole < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :arn
  attribute :assume_role_policy_document, type: :hash
  attribute :created_at,                  type: :time
  attribute :deleted_at,                  type: :time
  attribute :instance_profile,            type: :boolean
  attribute :name
  attribute :path
  attribute :policy_arn
  attribute :policy
  attribute :provisioned_id
  attribute :updated_at,                  type: :time
  attribute :user_managed_policy,         type: :boolean

  has_one :provider

  def save!
    requires :name, :provider_id

    params = {
      "url"      => self.collection.url,
      "iam_role" => {
        "assume_role_policy_document" => self.assume_role_policy_document,
        "instance_profile"            => self.instance_profile,
        "name"                        => self.name,
        "path"                        => self.path,
        "policy"                      => self.policy,
        "policy_arn"                  => self.policy_arn,
        "user_managed_policy"         => self.user_managed_policy,
      },
      "provider"    => self.provider_id,
    }

    params["iam_role"].reject! { |k,v| v.nil? }

    if new_record?
      self.connection.requests.new(self.connection.create_iam_role(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_iam_role("id" => self.id).body["request"])
  end
end
