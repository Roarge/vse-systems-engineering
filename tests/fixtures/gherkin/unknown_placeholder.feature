Feature: Unknown placeholder

  Scenario Template: Placeholder missing from some tables
    Given a value <v> in <unit>
      """
      <note>
      """
    When it is read
      | <v> | <missing> |
    Then it is shown
    And 1 < 2 and 3 > 2 still hold

    Scenarios: Complete
      | v | unit | note | missing |
      | 1 | C    | n    | m       |

    Scenarios: Lacks unit
      | v | note | missing |
      | 2 | n    | m       |

    Scenarios: Lacks note and missing
      | v | unit |
      | 3 | F    |
