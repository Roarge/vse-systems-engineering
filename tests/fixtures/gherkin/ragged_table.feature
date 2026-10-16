Feature: Ragged table

  Scenario: Rows of different widths
    Given the cells
      | a | b |
      | c |
      | d | e |
    When they are read
    Then they line up
