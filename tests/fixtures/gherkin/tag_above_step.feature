Feature: Tagged step

  Scenario: One
    Given a sensor
    @oops
    When it reports
    Then it is shown
