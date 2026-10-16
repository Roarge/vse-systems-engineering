Feature: Commit gates in continuous integration
  As an engineer using the plugin
  I want continuous integration to run the commit gates over the commits a pull request or push brings
  So that a fresh checkout with nothing staged cannot pass the gates without checking anything

  Continuous integration (CI) runs the pre-commit hook in range mode,
  which checks the files changed across a range of commits instead of
  the staged files. A pushed tag has no earlier commit to compare with,
  so for a tag CI checks every tracked file, in full-tree mode.

  Background:
    Given a VSE project at the light profile

  @wip
  Scenario: Range mode catches a story committed on a branch without a feature file
    Given a branch whose commits add a story file US_901_Example without a feature file
    And a fresh checkout of the branch with nothing staged
    When CI checks the range from main to the branch head
    Then the check fails with finding S1

  @wip
  Scenario: Full-tree mode runs on a tag
    Given a commit that adds a story file US_901_Example without a feature file
    And a later commit tagged v1.0.0 that changes only README.md
    When CI checks the push of the tag v1.0.0
    Then the check fails with finding S1
