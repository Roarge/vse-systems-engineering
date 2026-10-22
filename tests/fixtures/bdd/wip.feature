Feature: Work in progress

  Scenario: A finished scenario
    Given a passing step
    When I log "finished"
    Then a passing step

  @wip
  Scenario: An unfinished scenario
    Given a passing step
    When I log "unfinished scenario"
    Then a passing step

  @wip
  Rule: An unfinished rule

    Scenario: A scenario inside the unfinished rule
      Given a passing step
      When I log "unfinished rule"
      Then a passing step
