Feature: Environments
  In order to know what Engine Yard environments I can access
  As a User
  I want to be able to list the environments with which I'm associated

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have the following accounts:
      | Account Name  |
      | one           |
      | two           |
      | three         |
    And each of my accounts has several applications
    And each of my applications has an environment

  Scenario: Listing all of my environments
    When I run `ey-core environments`
    Then I see the name and ID for all of my environments

  Scenario Outline: Listing environments for a specific account
    When I run `ey-core environments <Account Flag> one`
    Then I see the environments in the one account
    But I do not see environments from other accounts

    Examples:
      | Account Flag  |
      | -a            |
      | --account     |

