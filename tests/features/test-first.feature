Feature: Test first
  As an engineer using the plugin
  I want a change to code to wait for a change to its tests wherever test first applies
  So that every piece of code arrives with the test that drove it

  Test first applies when the project's .iso-config.yaml records
  test_first with applies set to true. Its code_paths and test_paths
  say which files are code and which are tests.

  Background:
    Given a VSE project at the light profile

  Rule: In session, an edit to code waits for a test change

    Background:
      Given test first applies to code under src/ with tests under tests/

    Scenario: A code edit with no test change is denied
      Given no test file has changed
      When the agent edits src/reading.py
      Then the edit is denied
      And the denial asks for a failing test first

    Scenario: A code edit goes ahead once a test file has changed
      Given the file tests/test_reading.py has changed in the working tree
      When the agent edits src/reading.py
      Then the edit goes ahead

    Scenario: A refactor branch only draws a reminder
      Given the branch refactor/tidy-readings is checked out
      And no test file has changed
      When the agent edits src/reading.py
      Then the edit goes ahead
      And the agent is reminded that no test file has changed

  Rule: At commit, a project with nothing to test is not blocked

    Scenario: A project with no code and no record is not blocked at commit
      Given test first is not recorded
      And the project holds no code and no test tooling
      When the engineer commits a change to docs/project-plan.md
      Then the commit goes through
      And the engineer is told to record test first with /vse-test-first
