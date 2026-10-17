Feature: Gherkin-first and test-first gates at every profile
  As an engineer using the plugin
  I want the Gherkin-first and test-first gates to block at every profile
  So that a small project keeps the same behaviour-first and test-first floor as a large one

  A profile (light, standard or full) scales how much process the
  plugin asks of a project. These four gates do not scale. Each blocks
  by default, and only a recorded gate_overrides entry lowers one.

  Rule: The commit-time gates block at every profile

    Scenario Outline: A story without a feature file is refused at the <profile> profile
      Given a VSE project at the <profile> profile
      And a story file US_901_Example without a feature file
      When the engineer commits the story
      Then the commit is refused with finding S1

      Examples:
        | profile  |
        | light    |
        | standard |
        | full     |

    Scenario Outline: Code without a test change is refused at the <profile> profile
      Given a VSE project at the <profile> profile
      And test first applies to code under src/ with tests under tests/
      And no test file has changed
      When the engineer commits a change to src/reading.py
      Then the commit is refused by the gate precommit_test_first

      Examples:
        | profile  |
        | light    |
        | standard |
        | full     |

    Scenario: An override to warn lets the commit through with a warning
      Given a VSE project at the light profile
      And the gate precommit_gherkin is overridden to warn
      And a story file US_901_Example without a feature file
      When the engineer commits the story
      Then the commit goes through
      And the engineer is warned of finding S1

  Rule: At commit, the Gherkin gate reads every changed feature file in the model

    Scenario: A feature file in the model but outside a stories directory is refused
      Given a VSE project at the light profile
      When the engineer commits a change to model/features/US_901_Example.feature
      Then the commit is refused with finding F10

    Scenario: A feature file outside the model is left to the project
      Given a VSE project at the light profile
      When the engineer commits a change to features/login.feature
      Then the commit goes through

  Rule: The in-session gates block at every profile

    Scenario Outline: A new story without a feature file is denied at the <profile> profile
      Given a VSE project at the <profile> profile
      And no feature file for US_901_Example
      When the agent adds the story US_901_Example to a story file
      Then the edit is denied

      Examples:
        | profile  |
        | light    |
        | standard |
        | full     |

    Scenario Outline: A code edit with no test change is denied at the <profile> profile
      Given a VSE project at the <profile> profile
      And test first applies to code under src/ with tests under tests/
      And no test file has changed
      When the agent edits src/reading.py
      Then the edit is denied

      Examples:
        | profile  |
        | light    |
        | standard |
        | full     |
