Feature: Outline without examples

  Scenario Outline: No rows
    Given a value <v>
    When it is read
    Then it is shown
