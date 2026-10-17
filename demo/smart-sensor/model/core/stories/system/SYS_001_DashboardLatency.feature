# language: en
@SYS_001_DashboardLatency
Feature: Dashboard latency
  As an operator
  I want to deliver each reading from the device to the dashboard within a bounded latency
  So that the operator's view of the deployment site is timely enough to act on changing conditions

  @AC_readingRenderedInTime
  Scenario: A captured reading is rendered within 5 seconds at the 95th percentile
    Given the device is online and reporting at the nominal interval
    When a reading is captured at time t
    Then the dashboard renders that reading no later than t + 5 seconds at the 95th percentile over a 1-hour window
