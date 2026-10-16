# language: en
@US_Minimal
Feature: Show the latest reading
  As an operator
  I want to see the latest reading
  So that I can act on it

  @AC_latestReadingShown
  Scenario: The latest reading is shown
    Given a sensor that reported 21.5
    When the operator opens the dashboard
    Then the dashboard shows 21.5
