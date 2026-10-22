# language: en
@US_103_ExportReadings
Feature: Export the readings
  As an operator
  I want to export the readings as a file
  So that the readings can be shared

  @AC_exportFile
  Scenario: The export holds every reading
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
