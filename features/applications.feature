Feature: Applications
  In order to determine what I can work with
  As a User
  I want to be able to list the applications that live in my accounts

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have the following accounts:
      | Account Name  |
      | one           |
      | two           |
      | three         |
    And each of my accounts has several applications

  Scenario: Listing all of my applications
    When I run `ey-core applications`
    Then I see the name and ID for all of my applications

  Scenario Outline: Listing applications for a specific account
    When I run `ey-core applications <Account Flag> one`
    Then I see the name and ID for all applications in the one account
    But I do not see applications that belong to other accounts

    Examples:
      | Account Flag  |
      | -a            |
      | --account     |

