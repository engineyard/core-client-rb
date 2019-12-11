module ServerHelpers
  def known_servers
    begin
      recall_fact(:known_servers)
    rescue
      memorize_fact(:known_servers, [])
    end
  end

  def seen_servers
    begin
      recall_fact(:seen_servers)
    rescue
      memorize_fact(:seen_servers, [])
    end
  end

  def first_server
    known_servers.first
  end

  def last_server
    known_servers.last
  end
end

World(ServerHelpers)
