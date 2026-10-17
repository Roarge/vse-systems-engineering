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
