module DeploymentHelpers
  def known_deployments
    begin
      recall_fact(:known_deployments)
    rescue
      memorize_fact(:known_deployments, [])
    end
  end

  def first_deployment
    known_deployments.first.reload
  end

  def last_deployment
    known_deployments.last.reload
  end
end

World(DeploymentHelpers)
