Feature: Gherkin first in session
  As an engineer using the plugin
  I want an agent's edit to a story to wait until the story's feature file exists
  So that behaviour is described as scenarios before anyone designs or builds it

  The PreToolUse hook runs before each file edit the agent makes. It
  applies the proposed edit, compares the stories before and after, and
  gates only the stories that the edit adds or changes. A story file
  may hold several stories, as a register file does.

  Background:
    Given a VSE project at the light profile

  Scenario: A new story without a feature file is denied
    Given no feature file for US_901_Example
    When the agent adds the story US_901_Example to a story file
    Then the edit is denied
    And the denial names the feature file US_901_Example.feature

  Scenario: The same story goes ahead once its feature file exists
    Given a feature file for US_901_Example
    When the agent adds the story US_901_Example to a story file
    Then the edit goes ahead

  Scenario: An untouched story without a feature file only draws a warning
    Given a story file holding US_901_Example and US_902_Sibling
    And a feature file for US_901_Example
    And no feature file for US_902_Sibling
    When the agent changes the story US_901_Example
    Then the edit goes ahead
    And the agent is warned that US_902_Sibling has no feature file

  Scenario: Deleting a story is never denied
    Given a story file US_901_Example without a feature file
    When the agent deletes the story US_901_Example
    Then the edit goes ahead

  Scenario: Changing a gate override asks the engineer to confirm
    When the agent changes gate_overrides in .iso-config.yaml
    Then the engineer is asked to confirm the edit
