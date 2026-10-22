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
