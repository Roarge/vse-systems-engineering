# language: en
@US_241_ScenarioTags
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_firstReading @wip
  Scenario: Another tag beside the criterion tag
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  Scenario: No criterion tag
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  @AC_secondReading @AC_thirdReading
  Scenario: Two criterion tags
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  @AC_Fourth_reading
  Scenario: A name that is not lowerCamelCase
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  @AC_firstReading
  Scenario: A criterion name used twice
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
