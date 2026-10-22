Feature: A failing cleanup

  Scenario: A cleanup that raises fails a passing scenario
    Given a cleanup that logs "first cleanup"
    And a cleanup that raises
    When I log "scenario ran"
    Then a passing step
