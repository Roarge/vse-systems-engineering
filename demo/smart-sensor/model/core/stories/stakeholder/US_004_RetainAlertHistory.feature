# language: en
@US_004_RetainAlertHistory
Feature: Retain the alert history
  As a regulator
  I want to retain every alert in a tamper-evident store for the regulator-mandated retention window
  So that regulatory audits can reconstruct the full alert history of any deployment

  @AC_alertRetrievableUnmodified
  Scenario: An alert stays retrievable and unmodified within the retention window
    Given an alert raised at time t
    When the regulator's audit process queries the alert store at any time within the mandated retention window
    Then the alert is retrievable
    And a tamper-evidence check confirms the record is unmodified
