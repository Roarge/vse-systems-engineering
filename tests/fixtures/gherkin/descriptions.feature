Feature: Descriptions
  The feature description may span lines.

  # a comment inside the description is skipped
  It ends at the first child.

  Background: Shared context
    A background may carry a description.
    Given a sensor

  Scenario: Described scenario
    The scenario description comes before the first step.
    When it reports
    Then the reading is shown

  Scenario Outline: Described examples
    When it reports <v>
    Then the reading is shown

    Examples: Values
      Examples may carry a description too.
      | v |
      | 1 |
