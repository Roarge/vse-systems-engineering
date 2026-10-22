Feature: Late background

  Scenario: One
    Given a
    When b
    Then c

  Background:
    Given a sensor

  Rule: Late rule background

    Scenario: Two
      Given a
      When b
      Then c

    Background:
      Given a clock
