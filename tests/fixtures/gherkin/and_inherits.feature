Feature: Conjunctions inherit the kind of the step before

  Scenario: Every conjunction
    Given a sensor
    And a dashboard
    When the operator opens the dashboard
    But the network is slow
    Then the reading is shown
    * the timestamp is shown
