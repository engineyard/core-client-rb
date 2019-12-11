Feature: Version
  In order to determine if I'm working with the most recent goodness
  As a User
  I want to know what version of ey-core I'm using

  Scenario: Displaying the version
    When I run `ey-core version`
    Then I see the current ey-core version
