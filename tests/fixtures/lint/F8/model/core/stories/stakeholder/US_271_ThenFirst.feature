# language: en
@US_271_ThenFirst
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading
  Scenario: Then before When
    Given the device is switched on
    Then the reading is shown
    When it takes a reading
