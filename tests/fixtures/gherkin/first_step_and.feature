Feature: A first step cannot continue anything

  Scenario: Starts with And
    And a sensor
    When the operator opens the dashboard
    Then the reading is shown

  Scenario: Starts with a star
    * a sensor
    When the operator opens the dashboard
    Then the reading is shown
