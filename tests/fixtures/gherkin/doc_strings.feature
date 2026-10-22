Feature: Doc strings

  Scenario: Payloads
    Given a payload
      ```json
      {
        "reading": 21.5
      }
      ```
    When it is posted with a note
      """
        indented by two
      # not a comment

      ```
     less indented than the delimiter
      """
    Then the reply is accepted
