module AppHelpers
  def known_apps
    begin
      recall_fact(:known_apps)
    rescue
      memorize_fact(:known_apps, [])
    end
  end

  def first_app
    known_apps.first.reload
  end

  def last_app
    known_apps.last.reload
  end
end

World(AppHelpers)
