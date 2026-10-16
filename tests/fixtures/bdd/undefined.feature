Feature: An undefined step

  Scenario: A step nobody wrote
    Given a passing step
    When an undefined step nobody wrote
    Then I log "after the undefined step"
