Feature: A cleanup that exits

  Scenario: A cleanup that exits the interpreter fails a passing scenario
    Given a cleanup that logs "first cleanup"
    And a cleanup that exits with status 0
    When I log "scenario ran"

  Scenario: A later scenario still runs after a cleanup exits
    Given a passing step
    When I log "later scenario ran"
