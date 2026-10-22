Feature: One argument per step

  Scenario: Table then doc string
    Given the cells
      | a |
      """
      text
      """
    When a payload
      """
      text
      """
      | b |
    Then nothing more
