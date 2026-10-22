@US_Story # the story tag
Feature: A comment after the tags

  @AC_first @smoke #a comment, with no space after the hash
  Scenario: Tags with a trailing comment
    Given a value
    When it is read
    Then it is shown
