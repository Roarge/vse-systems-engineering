Feature: Rules group scenarios

  Background:
    Given a sensor

  Scenario: Before any rule
    When it reports
    Then the reading is shown

  @rule_one
  Rule: Readings are fresh
    Background:
      Given a clock

    Scenario: Fresh reading
      When a reading arrives
      Then it is fresh

    Scenario: Stale reading
      When no reading arrives
      Then it is stale

  Rule: Readings are bounded
    A rule may carry a description.

    Scenario: Bounded reading
      When a reading arrives
      Then it is within range
