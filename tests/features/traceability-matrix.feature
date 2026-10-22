Feature: Criterion coverage in the traceability matrix
  As an engineer using the plugin
  I want the traceability matrix to judge each acceptance criterion on its own
  So that a story reads complete only when a case reaches every one of its criteria

  The renderer tools/render/traceability-matrix.py generates the
  traceability matrix from the model. A verification or validation case
  reaches a criterion through a verify clause in its objective, as
  methodology section 11.3.3 sets out: verify <story> and
  verify <story>.acceptance reach every criterion of the story, and
  verify <story>.acceptance.<name> reaches the criterion <name> only.

  A stakeholder story is judged on its own criteria, as the story
  lint's finding S8 judges it before the story may move to inProgress
  (methodology section 11.4). A system story derived from it does not
  stand in for a criterion that no case reaches, however well that
  system story is verified.

  Scenario: A story with a criterion no case reaches is a gap
    Given a story file US_901_Example with the acceptance criteria firstReading and latestReadingShown
    And a validation case that verifies US_901_Example.acceptance.firstReading
    When the engineer renders the traceability matrix
    Then the matrix marks US_901_Example as Gap
    And the matrix lists the criterion latestReadingShown of US_901_Example under Gaps

  Scenario: A case that verifies the whole acceptance reaches every criterion
    Given a story file US_901_Example with the acceptance criteria firstReading and latestReadingShown
    And a validation case that verifies US_901_Example.acceptance
    When the engineer renders the traceability matrix
    Then the matrix marks US_901_Example as Complete

  Scenario: A verified system story does not cover the criteria of the story it derives from
    Given a story file US_901_Example with the acceptance criteria firstReading and latestReadingShown
    And a system story SYS_901_Example derived from US_901_Example with the acceptance criterion readingDelivered
    And a verification case that verifies SYS_901_Example.acceptance
    When the engineer renders the traceability matrix
    Then the matrix marks US_901_Example as Gap
    And the matrix lists the criterion firstReading of US_901_Example under Gaps
    And the matrix lists the criterion latestReadingShown of US_901_Example under Gaps
