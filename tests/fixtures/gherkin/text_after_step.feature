Feature: Stray text

  Scenario: Text after a step
    Given a sensor
    this line is not a step
    When it reports
    Then it is shown
