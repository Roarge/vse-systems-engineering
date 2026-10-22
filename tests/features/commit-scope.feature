Feature: The commit gates check the stories a change touches
  As an engineer using the plugin
  I want the commit gates to check the stories my change adds or alters
  So that I can migrate an existing project one story at a time, the way the in-session warning describes

  A change touches a story when it adds the story's declaration, alters
  the text of its block, or adds, changes, renames or deletes its
  feature file. The commit gate and the pull-request check read the
  stories a change touches and the feature files it changes. A story
  the change leaves alone is listed in one note instead, and the
  full-tree run at a release tag checks every story.

  Background:
    Given a VSE project at the light profile
    And a committed story file holding US_901_Example with its feature file and US_902_Legacy whose acceptance is legacy prose

  Scenario: An untouched legacy story beside the changed one does not block the commit
    When the engineer commits a change to the story US_901_Example only
    Then the commit goes through
    And the engineer is told that US_902_Legacy still needs migrating

  Scenario: The touched story without a feature file is refused
    When the engineer commits a change to the story US_902_Legacy only
    Then the commit is refused with finding S1

  Scenario: Changing only a story's feature file checks that story
    When the engineer commits a new feature file for US_902_Legacy only
    Then the commit is refused with finding S3

  Scenario: A pull request that changes only the migrated story passes
    Given a branch whose commits change only the story US_901_Example
    And a fresh checkout of the branch with nothing staged
    When CI checks the range from main to the branch head
    Then the check passes

  Scenario: The full-tree run at a release tag checks every story
    Given a later commit tagged v1.0.0 that changes only README.md
    When CI checks the push of the tag v1.0.0
    Then the check fails with finding S1
