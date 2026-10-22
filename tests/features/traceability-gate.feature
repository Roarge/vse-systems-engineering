Feature: The traceability gate checks the requirements a commit touches
  As an engineer using the plugin
  I want a commit that adds a requirement nothing verifies to be refused
  So that every requirement I add is traced to a verification case before it lands

  The traceability gate (precommit_traceability) reads the requirements
  and verification cases a commit adds or changes. A requirement is
  verified when a verification case anywhere in the model names it in a
  verify clause, directly or through a chain such as
  <story>.acceptance.<criterion>. At block, a touched requirement with
  no such clause stops the commit. The gate reads the model with the
  grep, sed and awk every supported platform ships, macOS included.

  Background:
    Given a VSE project at the light profile
    And the gate precommit_traceability is overridden to block
    And a story file US_901_Example with the acceptance criterion firstReading
    And a feature file for US_901_Example with a scenario tagged @AC_firstReading

  Scenario: A touched requirement that nothing verifies is refused
    When the engineer commits the story
    Then the commit is refused
    And the engineer is told that US_901_Example has no verification case

  Scenario: A touched requirement that a case verifies goes through
    Given a validation case that verifies US_901_Example.acceptance.firstReading
    When the engineer commits the story
    Then the commit goes through
