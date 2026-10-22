# language: en
@US_302_WithFeature
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_otherCriterion
  Scenario: A scenario whose criterion the story does not declare
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
