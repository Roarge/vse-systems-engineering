# language: en
@SYS_101_FirstReadingLatency
Feature: First reading latency
  As an operator
  I want to deliver the first reading within a bounded latency
  So that the operator sees the device working at once

  @AC_latencyMet
  Scenario: The first reading arrives in time
    Given the device is switched on
    When it takes a reading
    Then the reading is shown
