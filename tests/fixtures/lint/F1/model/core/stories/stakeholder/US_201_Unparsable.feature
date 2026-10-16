This line is not Gherkin.
# language: en
@US_201_Unparsable
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading
  Scenario: The scenario for firstReading
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
