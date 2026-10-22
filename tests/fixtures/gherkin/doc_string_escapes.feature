Feature: Escaped doc string delimiters

  Scenario: Delimiters inside doc strings
    Given a note
      """
      a \"\"\" inside
      a \`\`\` kept as written
      """
    When another note
      ```
      a \`\`\` inside
      a \"\"\" kept as written
      ```
    Then both are read
