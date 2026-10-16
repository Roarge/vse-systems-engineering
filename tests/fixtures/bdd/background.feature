Feature: A background fixture

  Background:
    Given I log "feature background"

  Scenario: A scenario at feature level
    Given I log "feature scenario"
    When a passing step
    Then a passing step

  Rule: A rule with its own background

    Background:
      Given I log "rule background"

    Scenario: A scenario inside the rule
      Given I log "rule scenario"
      When a passing step
      Then a passing step
