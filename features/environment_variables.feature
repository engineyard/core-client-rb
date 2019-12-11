Feature: Environment Variables
  In order to know current values of environment variables assigned to my Engine Yard environments
  As a User
  I want to be able to list the environment variables for environments which I'm associated

  Background:
    Given I'm an Engine Yard user
    And ey-core is configured with my cloud token
    And I have the following accounts:
      | Account Name  |
      | one           |
      | two           |
      | three         |
    And I have the following applications:
      | Account Name  | Application Name |
      | one           | blog_app         |
      | two           | todo_app         |
    And I have the following environments:
      | Application Name  | Environment Name  |
      | blog_app          | staging           |
      | blog_app          | production        |
      | todo_app          | staging           |
    And I have the following environment variables:
      | Name          | Value               | Application Name  | Environment Name  | Sensitive |
      | SECRET_BASE   | abc=                | blog_app          | staging           | false     |
      | DB_PASSWORD   | 123qweasd!!         | blog_app          | staging           | true      |
      | SECRET_BASE   | qwe=                | blog_app          | production        | false     |
      | DB_PASSWORD   | 987qweasd!!         | blog_app          | production        | true      |
      | DB_PASSWORD   | my_secure_password  | todo_app          | staging           | true      |

  Scenario: Listing all of my environment variables
    When I run `ey-core environment_variables`
    Then I see the name and value for all of my environments as well as name of associated environment and application

  Scenario Outline: Listing environment variables for a specific environment
    When I run `ey-core environment_variables <Environment Flag> staging`
    Then I see the environment variables associated with `staging` environment
    But I do not see environment variables associated with any other environments different from `staging`

    Examples:
      | Environment Flag  |
      | -e                |
      | --environment     |

  Scenario Outline: Listing environment variables for a specific application
    When I run `ey-core environment_variables <Application Flag> blog_app`
    Then I see the environment variables associated with `blog_app` application
    But I do not see environment variables associated with any other applications different from `blog_app`

    Examples:
      | Application Flag  |
      | -a                |
      | --application     |

