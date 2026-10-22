Feature: Story lint
  As an engineer using the plugin
  I want the story lint to check each story against its feature file
  So that every acceptance criterion is stated both as a scenario and as a named criterion

  The story lint is tools/lint/story-wellformed.py. It reports the
  findings of methodology section 11.9.1, with S codes for the story
  side and F codes for the feature file side. A named criterion is a
  requirement nested inside the story's acceptance, and the scenario
  that states it carries the matching @AC_ tag.

  Scenario: A story without a feature file fails S1
    Given a story file US_901_Example without a feature file
    When the engineer runs the story lint
    Then the lint reports finding S1 for US_901_Example

  Scenario: A feature file that holds no Feature fails S1
    Given a story file US_901_Example with the acceptance criterion firstReading
    And an empty feature file for US_901_Example
    When the engineer runs the story lint
    Then the lint reports finding S1 for US_901_Example

  Scenario: A criterion without a matching scenario tag fails S4
    Given a story file US_901_Example with the acceptance criterion firstReading
    And a feature file for US_901_Example with no scenarios
    When the engineer runs the story lint
    Then the lint reports finding S4 for US_901_Example

  Scenario: Acceptance prose outside a named criterion fails S3
    Given a story file US_901_Example whose acceptance is legacy prose
    And a feature file for US_901_Example
    When the engineer runs the story lint
    Then the lint reports finding S3 for US_901_Example

  Scenario: A story whose status cannot be read is held to the strictest row
    Given a story file US_901_Example with the acceptance criterion firstReading and no status
    And a feature file for US_901_Example with a scenario tagged @AC_firstReading
    When the engineer runs the story lint
    Then the lint reports finding S8 for US_901_Example

  Scenario: A verification case written on one line reaches its criterion
    Given a story file US_901_Example in progress with the acceptance criterion firstReading
    And a feature file for US_901_Example with a scenario tagged @AC_firstReading
    And a validation case written on one line that verifies US_901_Example.acceptance.firstReading
    When the engineer runs the story lint
    Then the lint reports no findings

  Scenario: A story whose criteria match its scenarios passes
    Given a story file US_901_Example with the acceptance criterion firstReading
    And a feature file for US_901_Example with a scenario tagged @AC_firstReading
    When the engineer runs the story lint
    Then the lint reports no findings
