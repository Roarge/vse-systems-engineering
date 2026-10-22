Feature: An interrupted run

  Scenario: An interrupt stops the run after the cleanups
    Given a cleanup that logs "cleanup after the interrupt"
    When I log "before the interrupt"
    And a step that is interrupted
    Then I log "after the interrupt"

  Scenario: A later scenario does not run after an interrupt
    When I log "later scenario ran"
