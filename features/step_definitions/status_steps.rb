def account
  client.accounts.get(recall_fact(:account_id))
end

Given %(I have an account) do
  memorize_fact(:account_id, create_account(client: client).id)
end

def app
  account.applications.get(recall_fact(:app_id))
end

Given %(my account has an application named super_app) do
  memorize_fact(
    :app_id,
    create_application(
      account: account,
      name: 'super_app'
    ).id
  )
end

def environment
  account.environments.get(recall_fact(:environment_id))
end

Given %(my application is associated with an environment named super_env) do
  memorize_fact(:environment_id, create_environment(account: account, app: app, environment: {name: 'super_env'}).id)
end

Then %(I see a message regarding my lack of deployments) do
  expect(output_text).to include(%{We couldn't find a deployment matching the criteria you provided.})
end

def deployment
  environment.deployments.get(recall_fact(:deployment_id))
end

def unweird_the_deployments
  # TODO: Figure out why this is necessary :/
  app_deployment = client.data[:application_deployments].keys.sort.last
  client.data[:application_deployments][app_deployment] = {
    application_id: app.id,
    environment_id: environment.id
  }
end

Given %(I've deployed the app) do
  unweird_the_deployments

  # This doesn't actually emit anything, though it works in the specs
  environment.deploy(app, ref: 'HEAD').resource!
  memorize_fact(
    :deployment_id,
    environment.deployments.first.id
  )
end

Then %(I see the details for the deployment) do
  expect(output_text).
    to match(/^.*:id.*=>.*#{Regexp.escape(deployment.id.to_s)}.*$/)
end

def deployment_1
  environment.deployments.get(recall_fact(:deployment_1_id))
end

def deployment_2
  environment.deployments.get(recall_fact(:deployment_2_id))
end


Given %(I've deployed the app twice) do
  unweird_the_deployments

  environment.deploy(app, ref: 'HEAD').resource!

  memorize_fact(
    :deployment_1_id,
    environment.deployments.first.id
  )

  environment.deploy(app, ref: 'HEAD').resource!

  memorize_fact(
    :deployment_2_id,
    environment.deployments.sort {|a,b| a.id <=> b.id}.last.id
  )
end

Then %(I see the details for the most recent deployment) do
  expect(output_text).
    to match(/^.*:id.*=>.*#{Regexp.escape(deployment_2.id.to_s)}.*$/)
end

Then %(I do not see the details for older deployments) do
  expect(output_text).
    not_to match(/^.*:id.*=>.*#{Regexp.escape(deployment_1.id.to_s)}.*$/)
end
