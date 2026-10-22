# language: en
@US_003_CalibrateInField
Feature: Calibrate in the field
  As a maintenance technician
  I want to calibrate the sensor against a reference probe in the field
  So that calibration drift is corrected without removing the device

  @AC_offsetStoredAndReported
  Scenario: The calibration offset is stored and reported on the next reading
    Given a portable reference probe at the deployment site
    When the technician runs the calibration command via the maintenance port
    Then the device stores the calibration offset
    And the device reports the calibration offset on the next reading
