Feature: An ambiguous step

  Scenario: Two definitions match one step
    Given a passing step
    When the ambiguous step
    Then I log "after the ambiguous step"
