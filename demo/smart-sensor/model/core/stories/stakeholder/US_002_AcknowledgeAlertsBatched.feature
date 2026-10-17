# language: en
@US_002_AcknowledgeAlertsBatched
Feature: Acknowledge alerts in a batch
  As an operator
  I want to acknowledge a batch of unacknowledged alerts in one action
  So that the alert queue clears quickly during incident storms

  @AC_allAlertsAcknowledged
  Scenario: Every shown alert is acknowledged within 1 second
    Given N unacknowledged alerts are shown
    When the operator selects "Acknowledge all"
    Then all N transition to acknowledged within 1 second
