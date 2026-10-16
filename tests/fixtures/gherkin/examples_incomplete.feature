Feature: Incomplete examples

  Scenario Outline: Header only and empty
    Given a value <v>
    When it is read
    Then it is shown

    Examples: Header only
      | v |

    Examples: Empty
