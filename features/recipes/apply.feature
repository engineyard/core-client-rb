Feature: Recipes Apply
  In order to keep my server configs up to date
  As a User
  I want to be able to apply config changes

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have an account named ACME Inc
    And ACME Inc has an application called anvil_drop
    And anvil_drop has the following environments:
      | Environment |
      | coyote      |
      | roadrunner  |

  Scenario: Applying changes to an environment (default behavior)
    When I run `ey-core recipes apply coyote`
    Then main recipes are applied to the coyote environment
    But no changes are made to the roadrunner environment

  Scenario Outline: Applying main recipes
    When I run `ey-core recipes apply <Main Flag> coyote`
    Then main recipes are applied to the coyote environment
    But no changes are made to the roadrunner environment

    Examples:
      | Main Flag |
      | -m        |
      | --main    |

  Scenario Outline: Applying custom recipes
    When I run `ey-core recipes apply <Custom Flag> coyote`
    Then custom recipes are applied to the coyote environment
    But no changes are made to the roadrunner environment

    Examples:
      | Custom Flag |
      | -c          |
      | --custom    |

  Scenario Outline: Performing a quick chef run
    When I run `ey-core recipes apply <Quick Flag> coyote`
    Then a quick run is applied to the coyote environment
    But no changes are made to the roadrunner environment

    Examples:
      | Quick Flag  |
      | -q          |
      | --quick     |

  Scenario Outline: Performing a full chef run
    When I run `ey-core recipes apply <Full Flag> coyote`
    Then main recipes are applied to the coyote environment
    And custom recipes are applied to the coyote environment
    But no changes are made to the roadrunner environment

    Examples:
      | Full Flag |
      | -f        |
      | --full    |

  Scenario Outline: Attempting to use more than one run type flag
    When I run `ey-core recipes apply <Run Type Flags> coyote`
    Then I'm advised that only one run type flag may be used
    And no changes are made to any environment

    Examples:
      | Run Type Flags  |
      | -m -c -q -f     |
      | -m -c -q        |
      | -m -c -f        |
      | -m -q -f        |
      | -c -q -f        |
      | -m -c           |
      | -m -q           |
      | -m -f           |
      | -c -q           |
      | -c -f           |
      | -q -f           |

  Scenario Outline: Applying changes to an environment on a specific account
    Given I have an account named Wile E Enterprises
    And Wile E Enterprises has an application called painted_tunnel
    And painted_tunnel has the following environments:
      | Environment |
      | coyote      |
      | roadrunner  |

    When I run `ey-core recipes apply coyote`
    Then I am advised that my criteria matched several environments
    And no changes are made to any environment

    When I run `ey-core recipes apply <Account Flag> 'ACME Inc' coyote`
    Then the main recipes are applied to the coyote environment for ACME Inc
    But no changes are made to any other environment

    Examples:
      | Account Flag  |
      | -a            |
      | --account     |
