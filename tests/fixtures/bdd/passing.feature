Feature: A passing fixture
  Every step of the scenario has a definition that passes.

  Scenario: Every step passes
    Given a passing step
    When I log "passing ran"
    Then the number 4 is even
