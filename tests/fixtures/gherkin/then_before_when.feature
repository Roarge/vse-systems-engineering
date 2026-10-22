Feature: Out of order

  Scenario: Then before When
    Given a sensor
    Then the reading is shown
    When the operator opens the dashboard
    And the operator refreshes it
    Then the reading is shown again
    When the operator closes the dashboard
