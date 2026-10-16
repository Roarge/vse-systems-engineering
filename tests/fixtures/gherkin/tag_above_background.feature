Feature: Tagged background

  @setup
  Background:
    Given a sensor

  Scenario: One
    When it reports
    Then it is shown
