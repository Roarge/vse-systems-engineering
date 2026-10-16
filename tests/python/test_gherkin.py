"""Unit tests for templates/tools/lint/gherkin.py, the stdlib Gherkin parser.

Each test reads a fixture from tests/fixtures/gherkin/ and asserts the
tree the parser builds or the findings it reports. Findings are compared
as (code, line) pairs, so a reworded message does not fail a test but a
missed or misplaced finding does.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import os
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
FIXTURES = os.path.join(REPO, "tests", "fixtures", "gherkin")

# The parser ships as a loose script beside the story lint, not as an
# installed package, so the test puts its directory on the path. No
# bytecode is written there, because the directory is mirrored byte for
# byte into the demo.
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(REPO, "templates", "tools", "lint"))

import gherkin  # noqa: E402
from gherkin import DocString, Step, Tag  # noqa: E402


def fixture_path(name):
    return os.path.join(FIXTURES, name)


def fixture_text(name):
    with open(fixture_path(name), encoding="utf-8") as handle:
        return handle.read()


def load(name):
    return gherkin.parse_file(fixture_path(name))


def pairs(findings):
    return [(finding.code, finding.line) for finding in findings]


def parse_pairs(name):
    return pairs(load(name).findings)


def structure_pairs(name):
    result = load(name)
    return pairs(gherkin.check_structure(result, fixture_path(name)))


class TreeTests(unittest.TestCase):
    def test_minimal_feature(self):
        result = load("minimal.feature")
        self.assertEqual(result.findings, [])
        feature = result.feature
        self.assertEqual(feature.name, "Show the latest reading")
        self.assertEqual(feature.line, 3)
        self.assertEqual(feature.language, "en")
        self.assertEqual(feature.tags, [Tag("@US_Minimal", 2)])
        self.assertEqual(
            feature.description,
            [
                "As an operator",
                "I want to see the latest reading",
                "So that I can act on it",
            ],
        )
        self.assertIsNone(feature.background)
        self.assertEqual(feature.rules, [])
        self.assertEqual(len(feature.scenarios), 1)
        scenario = feature.scenarios[0]
        self.assertEqual(scenario.keyword, "Scenario")
        self.assertFalse(scenario.outline)
        self.assertEqual(scenario.name, "The latest reading is shown")
        self.assertEqual(scenario.line, 9)
        self.assertEqual(scenario.tags, [Tag("@AC_latestReadingShown", 8)])
        self.assertEqual(scenario.description, [])
        self.assertEqual(scenario.examples, [])
        self.assertEqual(
            scenario.steps,
            [
                Step("Given", "given", "a sensor that reported 21.5", 10),
                Step("When", "when", "the operator opens the dashboard", 11),
                Step("Then", "then", "the dashboard shows 21.5", 12),
            ],
        )
        self.assertEqual(structure_pairs("minimal.feature"), [])

    def test_parse_uses_the_given_path_and_a_default(self):
        text = fixture_text("second_feature.feature")
        self.assertEqual(gherkin.parse(text).findings[0].path, "<string>")
        self.assertEqual(
            gherkin.parse(text, "a/b.feature").findings[0].path, "a/b.feature"
        )
        path = fixture_path("second_feature.feature")
        self.assertEqual(gherkin.parse_file(path).findings[0].path, path)

    def test_tags_attach_to_next_element(self):
        result = load("tags.feature")
        self.assertEqual(result.findings, [])
        feature = result.feature
        self.assertEqual(feature.tags, [Tag("@feature_tag", 1)])
        rule = feature.rules[0]
        self.assertEqual(rule.name, "Tagged rule")
        self.assertEqual(rule.tags, [Tag("@rule_tag", 4)])
        scenario = rule.scenarios[0]
        self.assertEqual(scenario.keyword, "Scenario Outline")
        self.assertTrue(scenario.outline)
        self.assertEqual(
            scenario.tags,
            [Tag("@first", 7), Tag("@second", 7), Tag("@third", 9)],
        )
        examples = scenario.examples[0]
        self.assertEqual(examples.name, "Values")
        self.assertEqual(examples.line, 16)
        self.assertEqual(examples.tags, [Tag("@examples_tag", 15)])
        self.assertEqual(examples.header, ["v"])
        self.assertEqual(examples.rows, [["1"]])

    def test_keyword_synonyms(self):
        result = load("synonyms.feature")
        self.assertEqual(result.findings, [])
        first, second = result.feature.scenarios
        self.assertEqual((first.keyword, first.outline), ("Example", False))
        self.assertEqual(
            (second.keyword, second.outline), ("Scenario Template", True)
        )
        examples = second.examples[0]
        self.assertEqual(
            (examples.name, examples.line, examples.header, examples.rows),
            ("", 13, ["x"], [["1"]]),
        )
        self.assertEqual(structure_pairs("synonyms.feature"), [])

    def test_descriptions(self):
        result = load("descriptions.feature")
        self.assertEqual(result.findings, [])
        feature = result.feature
        self.assertEqual(
            feature.description,
            [
                "The feature description may span lines.",
                "It ends at the first child.",
            ],
        )
        self.assertEqual(feature.background.name, "Shared context")
        self.assertEqual(
            feature.background.steps, [Step("Given", "given", "a sensor", 9)]
        )
        self.assertEqual(
            feature.scenarios[0].description,
            ["The scenario description comes before the first step."],
        )
        self.assertEqual(feature.scenarios[1].examples[0].rows, [["1"]])
        self.assertEqual(structure_pairs("descriptions.feature"), [])

    def test_and_inherits_kind(self):
        result = load("and_inherits.feature")
        steps = result.feature.scenarios[0].steps
        self.assertEqual(
            [step.keyword for step in steps],
            ["Given", "And", "When", "But", "Then", "*"],
        )
        self.assertEqual(
            [step.kind for step in steps],
            ["given", "given", "when", "when", "then", "then"],
        )
        self.assertEqual(result.findings, [])
        self.assertEqual(structure_pairs("and_inherits.feature"), [])

    def test_first_step_and_is_unknown_and_F8(self):
        result = load("first_step_and.feature")
        self.assertEqual(result.findings, [])
        first, second = result.feature.scenarios
        self.assertEqual(
            [step.kind for step in first.steps], ["unknown", "when", "then"]
        )
        self.assertEqual(
            [step.kind for step in second.steps], ["unknown", "when", "then"]
        )
        self.assertEqual(
            structure_pairs("first_step_and.feature"), [("F8", 4), ("F8", 9)]
        )

    def test_doc_string_backticks_and_indent_strip(self):
        result = load("doc_strings.feature")
        self.assertEqual(result.findings, [])
        steps = result.feature.scenarios[0].steps
        self.assertEqual(
            steps[0].doc_string,
            DocString("json", '{\n  "reading": 21.5\n}', 5),
        )
        self.assertEqual(
            steps[1].doc_string,
            DocString(
                "",
                "  indented by two\n"
                "# not a comment\n"
                "\n"
                "```\n"
                "less indented than the delimiter",
                11,
            ),
        )
        self.assertIsNone(steps[2].doc_string)
        self.assertEqual(steps[2].line, 18)

    def test_table_escapes(self):
        result = load("tables.feature")
        self.assertEqual(result.findings, [])
        step = result.feature.scenarios[0].steps[0]
        self.assertEqual(
            step.table,
            [
                ["plain", "pipe | inside", "back \\ slash", "new \n line",
                 "tab \\t kept"],
                ["padded", "b", "c", "d", "e"],
                ["\nedge", "g", "h", "i", "j"],
            ],
        )
        self.assertIsNone(result.feature.scenarios[0].steps[1].table)

    def test_rule_scenarios_in_all_scenarios(self):
        result = load("rules.feature")
        self.assertEqual(result.findings, [])
        feature = result.feature
        scenarios = feature.all_scenarios()
        self.assertEqual(
            [scenario.name for scenario in scenarios],
            ["Before any rule", "Fresh reading", "Stale reading",
             "Bounded reading"],
        )
        self.assertEqual([scenario.line for scenario in scenarios],
                         [6, 15, 19, 26])
        self.assertEqual(len(feature.scenarios), 1)
        self.assertEqual(feature.background.line, 3)
        self.assertEqual(feature.background.steps[0].text, "a sensor")
        fresh, bounded = feature.rules
        self.assertEqual((fresh.name, fresh.line), ("Readings are fresh", 11))
        self.assertEqual(fresh.tags, [Tag("@rule_one", 10)])
        self.assertEqual(fresh.background.steps[0].text, "a clock")
        self.assertEqual(bounded.name, "Readings are bounded")
        self.assertIsNone(bounded.background)
        self.assertEqual(structure_pairs("rules.feature"), [])

    def test_outline_expansion_substitutes_steps_docstrings_tables(self):
        result = load("outline.feature")
        self.assertEqual(result.findings, [])
        self.assertEqual(structure_pairs("outline.feature"), [])
        scenario = result.feature.scenarios[0]
        expanded = gherkin.expand_outline(scenario)
        self.assertEqual(
            [name for name, _steps in expanded],
            ["Reading 21.5 is shown", "Reading -3 is shown",
             "Reading 70 is shown"],
        )
        self.assertEqual(
            expanded[0][1],
            [
                Step("Given", "given", "a sensor that reported 21.5", 4,
                     doc_string=DocString("", "reading=21.5 unit=C", 5)),
                Step("When", "when", "the operator opens the dashboard", 8,
                     table=[["field", "shown"], ["value", "21.5"]]),
                Step("Then", "then", "the dashboard shows 21.5 C", 11),
            ],
        )
        self.assertEqual(expanded[2][1][2].text, "the dashboard shows 70 F")
        # The outline itself keeps its placeholders.
        self.assertEqual(scenario.steps[0].text,
                         "a sensor that reported <value>")
        self.assertEqual(scenario.steps[1].table[1], ["value", "<value>"])

    def test_expansion_keeps_unknown_placeholders(self):
        scenario = load("unknown_placeholder.feature").feature.scenarios[0]
        name, steps = gherkin.expand_outline(scenario)[2]
        self.assertEqual(name, "Placeholder missing from some tables")
        self.assertEqual(steps[0].text, "a value 3 in F")
        self.assertEqual(steps[0].doc_string.content, "<note>")
        self.assertEqual(steps[1].table, [["3", "<missing>"]])
        self.assertEqual(steps[3].text, "1 < 2 and 3 > 2 still hold")

    def test_expand_plain_scenario_returns_it_once(self):
        scenario = load("minimal.feature").feature.scenarios[0]
        self.assertEqual(
            gherkin.expand_outline(scenario),
            [(scenario.name, scenario.steps)],
        )


class ParseErrorTests(unittest.TestCase):
    def test_F1_first_keyword_not_feature(self):
        result = load("first_keyword_not_feature.feature")
        self.assertEqual(pairs(result.findings), [("F1", 2)])
        self.assertIsNone(result.feature)

    def test_F1_second_feature(self):
        result = load("second_feature.feature")
        self.assertEqual(pairs(result.findings), [("F1", 8)])
        self.assertEqual(result.feature.name, "First")
        self.assertEqual(
            [scenario.name for scenario in result.feature.all_scenarios()],
            ["One"],
        )

    def test_F1_text_where_keyword_required(self):
        self.assertEqual(parse_pairs("text_after_step.feature"), [("F1", 5)])

    def test_F1_step_outside_scenario(self):
        self.assertEqual(
            parse_pairs("step_outside_scenario.feature"), [("F1", 2)]
        )

    def test_F1_misplaced_table_doc_string_examples_and_step(self):
        self.assertEqual(
            parse_pairs("misplaced.feature"),
            [("F1", 2), ("F1", 4), ("F1", 8), ("F1", 20)],
        )

    def test_F1_unclosed_doc_string(self):
        self.assertEqual(
            parse_pairs("unclosed_doc_string.feature"), [("F1", 5)]
        )
        # Structure checks stay silent on a tree built around a parse
        # error, so the missing Then here is not reported as F8.
        self.assertEqual(structure_pairs("unclosed_doc_string.feature"), [])

    def test_F1_step_takes_one_doc_string_or_table(self):
        result = load("two_arguments.feature")
        self.assertEqual(pairs(result.findings), [("F1", 6), ("F1", 13)])
        first, second, _third = result.feature.scenarios[0].steps
        self.assertEqual((first.table, first.doc_string), ([["a"]], None))
        self.assertEqual(second.doc_string, DocString("", "text", 10))
        self.assertIsNone(second.table)

    def test_F1_ragged_table(self):
        result = load("ragged_table.feature")
        self.assertEqual(pairs(result.findings), [("F1", 6)])
        self.assertEqual(
            result.feature.scenarios[0].steps[0].table,
            [["a", "b"], ["d", "e"]],
        )

    def test_F1_tag_above_background(self):
        result = load("tag_above_background.feature")
        self.assertEqual(pairs(result.findings), [("F1", 3)])
        self.assertEqual(result.feature.background.line, 4)

    def test_F1_tag_above_step(self):
        self.assertEqual(parse_pairs("tag_above_step.feature"), [("F1", 5)])

    def test_F1_tag_not_followed_by_keyword(self):
        self.assertEqual(
            parse_pairs("tag_without_keyword.feature"), [("F1", 8)]
        )

    def test_F1_tag_token_without_at(self):
        result = load("tag_token_without_at.feature")
        self.assertEqual(pairs(result.findings), [("F1", 1)])
        self.assertEqual(result.feature.tags, [Tag("@US_Story", 1)])

    def test_F1_bare_at_asks_for_a_tag_name(self):
        result = load("tag_bare_at.feature")
        self.assertEqual(pairs(result.findings), [("F1", 1)])
        self.assertEqual(result.findings[0].message,
                         "a tag needs a name after @")
        self.assertEqual(result.feature.tags, [Tag("@US_Story", 1)])

    def test_F2_language_no(self):
        result = load("language_no.feature")
        self.assertEqual(pairs(result.findings), [("F2", 1)])
        self.assertIsNone(result.feature)


class StructureTests(unittest.TestCase):
    def test_F7_background_after_scenario(self):
        self.assertEqual(parse_pairs("background_after_scenario.feature"), [])
        self.assertEqual(
            structure_pairs("background_after_scenario.feature"),
            [("F7", 8), ("F7", 18)],
        )

    def test_F7_background_when_step(self):
        self.assertEqual(parse_pairs("background_when_step.feature"), [])
        self.assertEqual(
            structure_pairs("background_when_step.feature"),
            [("F7", 5), ("F7", 6)],
        )

    def test_F7_second_background(self):
        # The tree holds one Background per level, so the parser reports
        # the second one itself and keeps the first.
        result = load("second_background.feature")
        self.assertEqual(pairs(result.findings), [("F7", 6)])
        self.assertEqual(result.feature.background.line, 3)
        self.assertEqual(structure_pairs("second_background.feature"), [])

    def test_F8_then_before_when(self):
        # Only the first step out of order is reported. The And after it
        # inherits When and is out of order too, but adds no finding.
        self.assertEqual(
            structure_pairs("then_before_when.feature"), [("F8", 6)]
        )

    def test_F8_missing_then(self):
        self.assertEqual(
            structure_pairs("missing_then.feature"), [("F8", 3), ("F8", 7)]
        )

    def test_F9_outline_without_examples(self):
        self.assertEqual(
            structure_pairs("outline_without_examples.feature"), [("F9", 3)]
        )

    def test_F9_examples_without_header_or_rows(self):
        self.assertEqual(
            structure_pairs("examples_incomplete.feature"),
            [("F9", 8), ("F9", 11)],
        )

    def test_F9_unknown_placeholder(self):
        result = load("unknown_placeholder.feature")
        self.assertEqual(result.findings, [])
        findings = gherkin.check_structure(result, "unknown_placeholder")
        self.assertEqual(pairs(findings), [("F9", 4), ("F9", 4), ("F9", 8)])
        self.assertIn("<unit>", findings[0].message)
        self.assertIn("<note>", findings[1].message)
        self.assertIn("<missing>", findings[2].message)

    def test_F8_and_F9_inside_a_rule(self):
        self.assertEqual(parse_pairs("rule_structure.feature"), [])
        self.assertEqual(
            structure_pairs("rule_structure.feature"),
            [("F8", 7), ("F9", 9)],
        )

    def test_F9_examples_under_plain_scenario(self):
        result = load("examples_under_plain_scenario.feature")
        self.assertEqual(result.findings, [])
        self.assertEqual(len(result.feature.scenarios[0].examples), 1)
        self.assertEqual(
            structure_pairs("examples_under_plain_scenario.feature"),
            [("F9", 8)],
        )


class EncodingTests(unittest.TestCase):
    def test_bom_dropped_by_parse_file(self):
        text = fixture_text("minimal.feature")
        with tempfile.TemporaryDirectory() as scratch:
            path = os.path.join(scratch, "US_Minimal.feature")
            with open(path, "w", encoding="utf-8") as handle:
                handle.write("﻿" + text)
            result = gherkin.parse_file(path)
            self.assertEqual(result.findings, [])
            self.assertEqual(result.feature.name, "Show the latest reading")
            self.assertEqual(result, gherkin.parse(text, path))

    def test_bom_dropped_by_parse(self):
        # The story lint decodes a feature file itself and hands the text
        # to parse(), so parse() drops the byte order mark too.
        text = fixture_text("minimal.feature")
        result = gherkin.parse("﻿" + text, "US_Minimal.feature")
        self.assertEqual(result.findings, [])
        self.assertEqual(result, gherkin.parse(text, "US_Minimal.feature"))

    def test_only_one_bom_dropped(self):
        # A second U+FEFF is text, not a byte order mark, so the file does
        # not open with Feature.
        text = fixture_text("minimal.feature")
        with tempfile.TemporaryDirectory() as scratch:
            path = os.path.join(scratch, "US_Minimal.feature")
            with open(path, "w", encoding="utf-8") as handle:
                handle.write("﻿﻿" + text)
            for result in (gherkin.parse_file(path),
                           gherkin.parse("﻿﻿" + text, path)):
                self.assertEqual(pairs(result.findings), [("F1", 1)])

    def test_crlf_tolerated(self):
        for name in ("minimal.feature", "doc_strings.feature",
                     "tables.feature"):
            with self.subTest(fixture=name):
                text = fixture_text(name)
                crlf = text.replace("\n", "\r\n")
                self.assertIn("\r\n", crlf)
                result = gherkin.parse(crlf, name)
                self.assertIsNotNone(result.feature)
                self.assertEqual(result.findings, [])
                self.assertEqual(result, gherkin.parse(text, name))


class FindingTests(unittest.TestCase):
    def test_finding_format(self):
        finding = gherkin.Finding(
            "model/US_A.feature", 12, "F8", "scenario 'x' has no Then step"
        )
        self.assertEqual(
            finding.format(),
            "model/US_A.feature:12: F8 scenario 'x' has no Then step (§11)",
        )
        self.assertEqual(
            finding.as_dict(),
            {
                "path": "model/US_A.feature",
                "line": 12,
                "code": "F8",
                "message": "scenario 'x' has no Then step",
                "ref": "§11",
            },
        )


if __name__ == "__main__":
    unittest.main()
