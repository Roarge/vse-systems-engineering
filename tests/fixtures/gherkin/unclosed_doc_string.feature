Feature: Unclosed doc string

  Scenario: Never closed
    Given a payload
      """
      some text
    When it is posted
    Then it is accepted
