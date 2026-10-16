Feature: An outline fixture

  Scenario Outline: The number <number> is even
    Given a passing step
    When I log "row <number>"
    Then the number <number> is even

    Examples:
      | number |
      | 2      |
      | 3      |

    Examples: More rows
      | number |
      | 4      |
