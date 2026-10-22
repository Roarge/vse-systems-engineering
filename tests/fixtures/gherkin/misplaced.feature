Feature: Misplaced elements
  | a | b |
  | c | d |
  """
  text
  """

  Examples: Nowhere
    | x |

  Scenario Outline: Steps after Examples
    Given a <x>
    When b
    Then c

    Examples:
      | x |
      | 1 |

    Given too late
