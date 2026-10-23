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
  git, grep, sed and awk every supported platform ships, macOS
  included. A tool that fails while the gate reads the change is
  reported at the gate's disposition, naming the tool and its exit
  status. It is never read as a change that touches no requirement.

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

  Scenario Outline: A tool that fails while the gate reads the names is reported at <disposition>
    Given the gate precommit_traceability is overridden to <disposition>
    And grep fails with status 2 when the gate reads the requirement names
    When the engineer commits the story
    Then the commit <outcome>
    And the engineer is told that grep exited with status 2 while reading the story file

    Examples:
      | disposition | outcome      |
      | block       | is refused   |
      | warn        | goes through |
      | info        | goes through |

  Scenario: A tool that fails while the gate picks out the model files stops the commit
    Given grep fails with status 2 when the gate picks the model files out of the changed files
    When the engineer commits the story
    Then the commit is refused
    And the engineer is told that grep exited with status 2 while reading the list of changed files

  Scenario: A tool that fails while the gate reads the staged change stops the commit
    Given awk fails with status 2 when the gate reads the staged change
    When the engineer commits the story
    Then the commit is refused
    And the engineer is told that awk exited with status 2 while reading the story file
