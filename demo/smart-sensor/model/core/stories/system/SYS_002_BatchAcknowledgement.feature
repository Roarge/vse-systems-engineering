# language: en
@SYS_002_BatchAcknowledgement
Feature: Batch acknowledgement
  As an operator
  I want to transition every unacknowledged alert in a selected batch to acknowledged in one operation
  So that operator workload during alert storms remains tractable

  @AC_allAlertsTransitioned
  Scenario: A batch of up to 1000 alerts transitions within 1 second
    Given N unacknowledged alerts (N up to 1000) are shown
    When the operator selects "Acknowledge all"
    Then all N transition within 1 second
