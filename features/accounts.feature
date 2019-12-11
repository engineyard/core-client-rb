Feature: Accounts
  In order to know what Engine Yard accounts I can access
  As a User
  I want to be able to list the accounts with which I'm associated

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I'm associated with several accounts

  Scenario: Listing my accounts
    When I run `ey-core accounts`
    Then I see the name and ID of each of my accounts
