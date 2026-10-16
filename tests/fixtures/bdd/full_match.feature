Feature: A pattern matches the whole step text

  Scenario: Extra words after a defined step
    Given a passing step with extra words
    When I log "trailing words ran"
    Then a passing step

  Scenario: Extra words before a defined step
    Given surely a passing step
    When I log "leading words ran"
    Then a passing step
