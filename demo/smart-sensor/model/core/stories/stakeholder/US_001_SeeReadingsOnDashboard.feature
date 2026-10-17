# language: en
@US_001_SeeReadingsOnDashboard
Feature: See readings on the dashboard
  As an operator
  I want to see live temperature and humidity readings on a dashboard
  So that deployment-site conditions are visible without on-site visits

  @AC_latestReadingShown
  Scenario: The latest reading appears within 5 seconds of arrival
    Given the device is online and reporting
    When the operator opens the dashboard
    Then the latest reading is displayed within 5 seconds of arrival at the cloud broker
