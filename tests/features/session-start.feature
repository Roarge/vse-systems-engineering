Feature: Session start report
  As an engineer using the plugin
  I want each session in a VSE project to open with the project's state and policy
  So that the agent starts from what the project records, not from guesses

  The SessionStart hook prints plain text that Claude Code adds to the
  conversation. A VSE project is located through its .iso-config.yaml,
  the way the gates locate it.

  Rule: The session finds the project through its configuration

    Scenario: A session started below the project directory reports the project above it
      Given a VSE project at the full profile
      When a session starts in the directory src/deep
      Then the session is told the project runs at the full profile

  Rule: The session is told the test-first policy the project records

    Scenario: A project where test first applies points the agent at the test-driven development skill
      Given a VSE project at the light profile
      And test first applies to code under src/ with tests under tests/
      When a session starts in the project directory
      Then the session is told that test first applies
      And the session is pointed at the superpowers test-driven-development skill
      And the session is told to work Gherkin first

    Scenario: A project where test first does not apply is told it is not required there
      Given a VSE project at the light profile
      And test first is recorded as not applying
      When a session starts in the project directory
      Then the session is told that test first is not required here
      And the session is not pointed at the superpowers test-driven-development skill
      And the session is told to work Gherkin first

    Scenario: A project with test tooling and no record is asked to record test first
      Given a VSE project at the light profile
      And test first is not recorded
      And the project holds the file pytest.ini
      When a session starts in the project directory
      Then the session is asked to record test first with /vse-test-first
      And the session is told that test tooling was found
      And the session is pointed at the superpowers test-driven-development skill

    Scenario: A session started below the project directory still finds the project's test tooling
      Given a VSE project at the light profile
      And test first is not recorded
      And the project holds the file pytest.ini
      When a session starts in the directory src/deep
      Then the session is told that test tooling was found
