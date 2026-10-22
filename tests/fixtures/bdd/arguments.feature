Feature: Step arguments

  Scenario: A doc string and a table reach their steps
    Given the doc string reads "hello"
      """
      hello
      """
    When the table has 2 rows and its first cell is name
      | name  |
      | value |
    Then the step has no doc string or table
