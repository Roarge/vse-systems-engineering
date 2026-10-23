Feature: Prompt, compaction, notification and branch reminders wherever the project is found
  As an engineer using the plugin
  I want the prompt, compaction, notification and branch-switch hooks to find my project the way the gates do
  So that a project that holds only its configuration, or a session started below it, still gets its reminders

  The UserPromptSubmit, PreCompact and Notification hooks know only the
  session's working directory. They locate the project from it through
  its .iso-config.yaml, the canonical project marker, as the
  SessionStart hook does. The project-side post-checkout git hook,
  which git runs at the top level of the repository, locates it the
  same way. The project in these scenarios holds its configuration and
  no methodology/ folder. A Change Request whose opening date the
  Notification hook cannot read is skipped, so it cannot hide the
  stale Change Requests beside it.

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

    Scenario: A stale Change Request is still reported beside one whose opening date cannot be read
      Given a VSE project at the standard profile
      And a Change Request has been open for 20 days
      And a Change Request whose opening date cannot be read
      When a notification arrives in the directory src/deep
      Then the engineer is told that 1 Change Request has been open more than 14 days

  Rule: The branch-switch git hook finds the project through its configuration

    Scenario: Switching to a story branch reports the story branch
      Given a VSE project at the standard profile
      When the engineer switches to the new branch story/US_001_Readings
      Then the engineer is told that story/US_001_Readings is a story branch
