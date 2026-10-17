# language: en
@SYS_004_AlertRetentionWindow
Feature: Alert retention window
  As a regulator
  I want to write every raised alert to an append-only store with an integrity digest and keep the record queryable for the mandated retention period
  So that an audit query at any instant inside the retention period returns the complete alert set together with its integrity evidence

  @AC_alertReturnedWithRecordedDigest
  Scenario: An audit query inside the retention period returns the alert with its recorded digest
    Given an alert raised at time t
    When an audit query runs at any instant between t and t plus the retention period
    Then the store returns that alert with a digest that matches the value recorded at t
