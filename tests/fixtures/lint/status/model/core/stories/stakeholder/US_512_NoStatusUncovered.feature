# language: en
@US_512_NoStatusUncovered
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading
  Scenario: The first reading is shown
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
