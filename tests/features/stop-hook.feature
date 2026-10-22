Feature: Stop reminders that never loop
  As an engineer using the plugin
  I want the stop hooks to remind the agent of a missing test once for each state of the working tree
  So that a reminder never keeps the agent's turn going round in a loop

  The Stop hook runs when the agent ends its turn, and the SubagentStop
  hook runs when a subagent ends its own. Claude Code sets
  stop_hook_active to true while the agent is already carrying on
  because a stop hook asked it to. Each hook keeps its own record of
  the states it has spoken in, so a subagent never uses up what the
  main agent is told. The record keeps the reminders for the engineer
  and the test-first reminder for the agent apart, so one never uses up
  the other.

  Background:
    Given a VSE project at the light profile
    And test first applies to code under src/ with tests under tests/
    And the file src/reading.py has changed in the working tree
    And no test file has changed

  Scenario Outline: The <hook> hook is silent while a stop hook is active
    When the <hook> hook runs with stop_hook_active set to true
    Then the <hook> hook stays silent

    Examples:
      | hook         |
      | Stop         |
      | SubagentStop |

  Scenario: The first stop in a state draws the test-first reminder
    When the Stop hook runs
    Then the agent receives the test-first reminder

  Scenario: A second stop in the same state draws no reminder
    Given the Stop hook has sent the test-first reminder for the current state
    When the Stop hook runs
    Then the agent receives no test-first reminder

  Scenario: A stop in a new state draws the reminder again
    Given the Stop hook has sent the test-first reminder for the current state
    And the file src/sensor.py has changed in the working tree
    When the Stop hook runs
    Then the agent receives the test-first reminder

  Scenario: A subagent's reminder does not use up the main agent's
    Given the SubagentStop hook has sent the test-first reminder for the current state
    When the Stop hook runs
    Then the agent receives the test-first reminder

  Scenario: A reminder for the engineer goes out once for each state
    Given the file model/core/logical-architecture/sensor.sysml has changed in the working tree
    And the Stop hook has reminded the engineer to write an ADR for the current state
    When the Stop hook runs
    Then the engineer receives no reminder

  Scenario: A finding that falls due after a reminder in the same state is still sent
    Given the file model/core/logical-architecture/sensor.sysml has changed in the working tree
    And the branch refactor/tidy is checked out
    And the Stop hook has reminded the engineer to write an ADR for the current state
    And the branch feat/x is checked out
    When the Stop hook runs
    Then the agent receives the test-first reminder
    And the engineer receives no reminder
