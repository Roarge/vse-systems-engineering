# language: en
#
# System story feature file (§11.2).
#
# Behaviour comes first. Write this file before the story's SysML, then
# mirror each scenario in the story (§11.4). Copy it beside the .sysml
# file that declares the story and name the copy after the story, for
# example SYS_001_Example.feature. A file whose name begins with _ is a
# template and is not checked.
#
# The Feature carries one tag, the story identifier. The three narrative
# lines repeat the story's role, capability and benefit. A system story
# keeps the role of the stakeholder story it derives from and restates
# the capability in system-internal vocabulary (§5.4.1). The role names
# the part definition that types the story's role, with spaces and
# letter case ignored. The capability and the benefit repeat the story's
# strings word for word.
#
# Each scenario states one acceptance criterion, as one concrete example
# written in Given, When and Then steps, with the outcome stated against
# a measurable threshold. It carries one @AC_<name> tag, with <name> in
# lowerCamelCase (words run together, the first in lower case and each
# later one capitalised, as in exampleCriterion), and the story mirrors
# it with requirement <name> nested inside requirement :>> acceptance
# (§11.3.1).

@SYS_001_Example
Feature: <short title of the system story>
  As an operator
  I want to (system-internal restatement of US_<NNN> capability)
  So that (value the role gains, sharpened towards measurable form)

  @AC_exampleCriterion
  Scenario: <one concrete example of the behaviour, with its threshold>
    Given <preconditions>
    When <action>
    Then <observable outcome with measurable threshold>
