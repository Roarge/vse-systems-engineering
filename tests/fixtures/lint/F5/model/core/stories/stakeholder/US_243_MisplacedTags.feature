# language: en
@US_243_MisplacedTags @AC_onFeature
Feature: See the first reading
  As an operator
  I want to see the first reading
  So that the device is known to work

  @AC_onRule
  Rule: Readings are shown

    @AC_firstReading
    Scenario Outline: The reading <value> is shown
      Given the device reads <value>
      When it takes a reading
      Then the reading is shown

      @AC_onExamples
      Examples:
        | value |
        | 1     |
