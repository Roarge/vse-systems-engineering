Feature: No outcome or no action

  Scenario: Missing Then
    Given a sensor
    When the operator opens the dashboard

  Scenario: Missing When
    Given a sensor
    Then the reading is shown
