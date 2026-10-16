Feature: Examples under a plain scenario

  Scenario: Not an outline
    Given a value <v>
    When it is read
    Then it is shown

    Examples:
      | v |
      | 1 |
