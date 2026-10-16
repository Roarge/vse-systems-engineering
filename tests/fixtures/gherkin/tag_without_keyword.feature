Feature: Dangling tags

  Scenario: One
    Given a sensor
    When it reports
    Then it is shown

  @dangling
