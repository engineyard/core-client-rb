Feature: Docker Registry Credentials
  In order to authorize the Docker Engine with the AWS ECR registry
  As a User
  I want to be able to retrieve the Docker authorization credentials

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have the following accounts:
      | Account Name  |
      | one           |
      | two           |

  Scenario Outline: Retrieving Docker authorization credentials
    When I run `ey-core get-docker-registry-login <Account Flag> one <Location Flag> us-east-1`
    Then I see the docker login command

    Examples:
      | Account Flag  | Location Flag |
      | -c            | -l            |
      | --account     | --location    |
