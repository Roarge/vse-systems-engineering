Feature: Commit gates in continuous integration
  As an engineer using the plugin
  I want continuous integration to run the commit gates over the commits a pull request or push brings
  So that a fresh checkout with nothing staged cannot pass the gates without checking anything

  Continuous integration (CI) runs the pre-commit hook in range mode,
  which checks the files changed across a range of commits instead of
  the staged files. A pushed tag has no earlier commit to compare with,
  so for a tag CI checks every tracked file, in full-tree mode. For a
  push, test before code counts a test changed on the branch since its
  merge base as well as the range, so a push that brings the code
  counts the test an earlier push brought.

  Background:
    Given a VSE project at the light profile

  Scenario: Range mode catches a story committed on a branch without a feature file
    Given a branch whose commits add a story file US_901_Example without a feature file
    And a fresh checkout of the branch with nothing staged
    When CI checks the range from main to the branch head
    Then the check fails with finding S1

  Scenario: A push of code counts the test pushed earlier on its branch
    Given test first applies to code under src/ with tests under tests/
    And a branch feature/readings whose commits add the test file tests/test_reading.py
    And a later push to the branch that adds only the code file src/reading.py
    And a fresh checkout of the branch with nothing staged
    When CI checks the later push
    Then the check passes

  Scenario: Full-tree mode runs on a tag
    Given a commit that adds a story file US_901_Example without a feature file
    And a later commit tagged v1.0.0 that changes only README.md
    When CI checks the push of the tag v1.0.0
    Then the check fails with finding S1
