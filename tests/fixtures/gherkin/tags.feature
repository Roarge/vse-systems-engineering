@feature_tag
Feature: Tags attach to the next element

  @rule_tag
  Rule: Tagged rule

    @first @second
    # a comment between tag lines
    @third
    Scenario Outline: Tagged outline
      Given a value <v>
      When it is read
      Then it is <v>

      @examples_tag
      Examples: Values
        | v |
        | 1 |
