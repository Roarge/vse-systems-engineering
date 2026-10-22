# language: en
@US_281_NoExamples
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading
  Scenario Outline: Readings in <unit>
    Given the device reports in <unit>
    When it takes a reading
    Then the reading is shown in <unit>
