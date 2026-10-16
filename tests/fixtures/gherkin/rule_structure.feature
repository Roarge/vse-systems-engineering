Feature: Structure findings inside a Rule

  Rule: Readings are checked
    Scenario: Then before When inside a Rule
      Given a sensor
      Then the reading is shown
      When the operator opens the dashboard

    Scenario Outline: No Examples inside a Rule
      Given a value <v>
      When it is read
      Then it is shown
