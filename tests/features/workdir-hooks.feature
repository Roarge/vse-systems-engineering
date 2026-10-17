Feature: Prompt, compaction and notification reminders wherever the project is found
  As an engineer using the plugin
  I want the prompt, compaction and notification hooks to find my project the way the gates do
  So that a project that holds only its configuration, or a session started below it, still gets its reminders

  The UserPromptSubmit, PreCompact and Notification hooks know only the
  session's working directory. They locate the project from it through
  its .iso-config.yaml, the canonical project marker, as the
  SessionStart hook does. The project in these scenarios holds its
  configuration and no methodology/ folder.

  Rule: The working-directory hooks find the project through its configuration

    Scenario: A prompt to change a baselined artefact draws the change request reminder
      Given a VSE project at the standard profile
      When the engineer submits the prompt "update the risk register" in the project directory
      Then the agent is reminded to raise a Change Request

    Scenario: A prompt in a directory below the project draws the change request reminder
      Given a VSE project at the standard profile
      When the engineer submits the prompt "update the risk register" in the directory src/deep
      Then the agent is reminded to raise a Change Request

    Scenario: Compaction in a directory below the project saves a state snapshot
      Given a VSE project at the standard profile
      When the context is compacted in the directory src/deep
      Then a state snapshot of the project is saved

    Scenario: A notification in a directory below the project reports a stale Change Request
      Given a VSE project at the standard profile
      And a Change Request has been open for 20 days
      When a notification arrives in the directory src/deep
      Then the engineer is told that 1 Change Request has been open more than 14 days
