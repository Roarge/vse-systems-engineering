This line comes before the Feature keyword.
Feature: A parse error

  Scenario: Never runs
    Given a passing step
    When I log "parse error ran"
    Then a passing step
