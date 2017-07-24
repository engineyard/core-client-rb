Feature: Whoami
  In order to ensure that I'm logged into the right account
  As a User
  I want to be able to see my user information

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token

  Scenario: Getting the current user information
    When I run `ey-core whoami`
    Then I should see my user ID
    And I should see my email address
    And I should see my name
