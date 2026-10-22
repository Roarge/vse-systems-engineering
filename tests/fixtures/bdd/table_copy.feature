Feature: A step that changes its table

  Background:
    Given I take the header row from a table of 2 rows headed name
      | name  |
      | value |

  Scenario: The first scenario takes the header row
    When I log "first scenario"
    Then a passing step

  Scenario: The second scenario sees the whole table again
    When I log "second scenario"
    Then a passing step
