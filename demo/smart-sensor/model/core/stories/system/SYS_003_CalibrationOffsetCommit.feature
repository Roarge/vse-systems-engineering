# language: en
@SYS_003_CalibrationOffsetCommit
Feature: Calibration offset commit
  As a maintenance technician
  I want to accept a reference measurement on the maintenance port, derive a calibration offset, persist it across power cycles, and apply it to every subsequent reading
  So that the technician confirms a corrected reading before leaving the deployment site

  @AC_offsetPersistedAndApplied
  Scenario: The stored offset survives a power cycle and corrects the next published reading
    Given a calibration command carrying a reference value
    When the device accepts it on the maintenance port
    Then the stored offset survives a power cycle
    And the next reading published to the cloud carries the corrected value
