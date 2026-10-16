Feature: A failing fixture

  Scenario: An odd number is not even
    Given a passing step
    When I log "failing ran"
    Then the number 3 is even
    And I log "after the failure"

  Scenario: A later scenario still runs
    Given a passing step
    When I log "later scenario ran"
    Then the number 2 is even
