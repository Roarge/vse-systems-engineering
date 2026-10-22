Feature: A step that exits

  Scenario: A step that exits the interpreter fails its scenario
    Given a cleanup that logs "cleanup after the exit"
    When I log "before the exit"
    And a step that exits with status 0
    Then I log "after the exit"

  Scenario: A later scenario still runs after an exit
    Given a passing step
    When I log "later scenario ran"
