# language: en
@US_182_OneCriterionUncovered
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading
  Scenario: The scenario for firstReading
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  @AC_readingUnit
  Scenario: The scenario for readingUnit
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
