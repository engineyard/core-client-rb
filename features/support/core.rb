module CoreHelpers
  def client
    begin
      recall_fact(:client)
    rescue
      memorize_fact(:client, create_client)
    end
  end

  def current_user
    client.users.current
  end

  def current_user_hash
    client.current_user
  end
end

World(CoreHelpers)
