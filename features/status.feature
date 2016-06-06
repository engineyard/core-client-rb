Feature: Status
  In order to know if my app is healthy
  As a User
  I want to see the details of the app deployments

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have an account
    And my account has an application named super_app
    And my application is associated with an environment named super_env

  Scenario: Getting the status with no deployments
    When I run `ey-core status super_env super_app`
    Then I see a message regarding my lack of deployments

  Scenario: Getting the status with one deployment
    Given I've deployed the app
    When I run `ey-core status super_env super_app`
    Then I see the details for the deployment

  Scenario: Getting the status with more than one deployment
    Given I've deployed the app twice
    When I run `ey-core status super_env super_app`
    Then I see the details for the most recent deployment
