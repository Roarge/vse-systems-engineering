Feature: Scenarios in the generated requirements documents
  As an engineer using the plugin
  I want the generated requirements documents to show each acceptance criterion as its scenario
  So that a reviewer reads the same steps that the feature file holds

  The renderers under tools/render/ generate the requirements documents
  from the model. A scenario is matched to its criterion by the
  scenario's @AC_ tag. In Markdown, a fenced block sits between two
  lines of three backticks, and the word gherkin after the opening
  backticks names its language.

  Scenario: The stakeholder requirements document shows each scenario as a fenced gherkin block
    Given a story file US_901_Example with the acceptance criteria firstReading and latestReadingShown
    And a feature file for US_901_Example with scenarios tagged @AC_firstReading and @AC_latestReadingShown
    When the engineer renders the stakeholder requirements document
    Then the document shows the scenario tagged @AC_firstReading in a fenced gherkin block
    And the document shows the scenario tagged @AC_latestReadingShown in a fenced gherkin block

  Scenario: A criterion without a feature file falls back to its doc text
    Given a story file US_901_Example with the acceptance criterion firstReading
    And no feature file for US_901_Example
    When the engineer renders the stakeholder requirements document
    Then the document shows the doc text of the criterion firstReading
