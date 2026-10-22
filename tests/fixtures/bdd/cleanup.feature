Feature: A cleanup fixture

  Scenario: Cleanups run after a failing step
    Given a cleanup that logs "first cleanup"
    And a cleanup that logs "second cleanup"
    When I log "before the failure"
    Then the number 3 is even
