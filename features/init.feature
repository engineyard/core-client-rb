Feature: Init
  This command is deprecated

  Scenario: Running init
    When I run `ey-core init`
    Then I am advised that this command has been deprecated
