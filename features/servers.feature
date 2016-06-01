Feature: Servers
  In order to determine what servers I can access
  As a User
  I want to see a list of servers with which I'm associated

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
    And each of my environments has a server

  Scenario: Listing all of my servers
    When I run `ey-core servers`
    Then I see the name, role, and provisioned ID for all of my servers

  Scenario Outline: Listing servers for a specific account
    When I run `ey-core servers <Account Flag> one`
    Then I see the servers in the one account
    But I do not see servers from other accounts

    Examples:
      | Account Flag  |
      | -a            |
      | --account     |

  Scenario Outline: Listing severs for a specific environment
    When I run `ey-core servers <Environment Flag> one_1_env`
    Then I see the servers in the one_1_env environment
    But I do not see servers from other environments

    Examples:
      | Environment Flag  |
      | -e                |
      | --environment     |

  Scenario: Ambiguous environments
    Given the two account has an environment named one_1_env with a server
    When I run `ey-core servers -e one_1_env`
    Then I do not see any servers
    But I am advised that my filters yielded ambiguous results

  Scenario: Listing servers for a specific account and environment
    When I run `ey-core servers -a one -e one_1_env`
    Then I see the servers from the one_1_env environment in the one account
    But I do not see any other servers

  Scenario: Account and environment filters down to no results
    When I run `ey-core servers -a one -e two_1_env`
    Then I do not see any servers
    But I am advised that my filters matched no servers
