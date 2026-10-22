"""Unit tests for templates/tools/render/sysml_model.py, the model reader.

The renderers and the story lint share this reader. These tests cover
the comment stripping that both rely on.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
STORIES = os.path.join(REPO, "tests", "fixtures", "stories")

# The reader ships as a loose script beside the renderers, so the test
# puts its directory on the path. No bytecode is written there, because
# the directory is mirrored byte for byte into the demo.
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(REPO, "templates", "tools", "render"))

import sysml_model  # noqa: E402


class NoteTests(unittest.TestCase):
    def test_note_is_stripped_with_its_line_breaks(self):
        clean, docs = sysml_model._strip_comments(
            "a //* one\ntwo } */ b\nc // line\n")
        self.assertEqual(clean, "a \n b\nc \n")
        self.assertEqual(docs, [])

    def test_note_hides_the_declarations_inside_it(self):
        model = sysml_model.Model(project_root=Path(STORIES), model_root="")
        sysml_model.parse_file(Path(STORIES),
                               Path(STORIES) / "note-syntax.sysml", model)
        self.assertEqual(
            [story.identifier for story in model.stories],
            ["US_301_AfterNote", "US_302_Last"],
        )


def parse_text(text):
    """The model read from `text` as one .sysml file."""
    with tempfile.TemporaryDirectory() as root:
        path = Path(root) / "cases.sysml"
        path.write_text(text, encoding="utf-8")
        model = sysml_model.Model(project_root=Path(root), model_root="")
        sysml_model.parse_file(Path(root), path, model)
    return model


def verifies(model):
    return [(case.identifier, case.verifies) for case in model.cases]


class OneLineCaseTests(unittest.TestCase):
    def test_case_written_on_one_line_keeps_its_verify(self):
        # The form of the case table in methodology section 4.
        model = parse_text(
            "package V {\n"
            "    verification def VAL_1 { subject s : ExampleSystem; "
            "objective { verify US_1_X.acceptance.firstReading; } }\n"
            "}\n")
        self.assertEqual(verifies(model), [
            ("VAL_1", [("US_1_X", "acceptance.firstReading")]),
        ])

    def test_package_and_case_on_one_line(self):
        model = parse_text(
            "package V { verification def VAL_1 { subject s : "
            "ExampleSystem; objective { verify US_1_X.acceptance.a; "
            "verify US_1_X.acceptance.b; } } }\n")
        self.assertEqual(verifies(model), [
            ("VAL_1", [("US_1_X", "acceptance.a"),
                       ("US_1_X", "acceptance.b")]),
        ])

    def test_each_case_on_a_line_keeps_its_own_verify(self):
        model = parse_text(
            "package V {\n"
            "    verification def VAL_1 { objective { verify US_1_X; } } "
            "verification def VC_2 { objective { verify SYS_2_Y.acceptance; "
            "} }\n"
            "}\n")
        self.assertEqual(verifies(model), [
            ("VAL_1", [("US_1_X", "")]),
            ("VC_2", [("SYS_2_Y", "acceptance")]),
        ])

    def test_case_left_open_on_its_line_reads_later_lines(self):
        # The last case on the line stays open, so the verify clauses on
        # the lines after it are its own.
        model = parse_text(
            "package V {\n"
            "    verification def VAL_1 { objective { verify US_1_X; } } "
            "verification def VAL_2 {\n"
            "        objective { verify US_2_Y.acceptance.b; }\n"
            "    }\n"
            "}\n")
        self.assertEqual(verifies(model), [
            ("VAL_1", [("US_1_X", "")]),
            ("VAL_2", [("US_2_Y", "acceptance.b")]),
        ])

    def test_verify_before_a_header_belongs_to_the_open_case(self):
        model = parse_text(
            "package V {\n"
            "    verification def VAL_1 {\n"
            "        objective { verify US_1_X; } } verification def VAL_2 "
            "{ objective { verify US_2_Y; } }\n"
            "}\n")
        self.assertEqual(verifies(model), [
            ("VAL_1", [("US_1_X", "")]),
            ("VAL_2", [("US_2_Y", "")]),
        ])


if __name__ == "__main__":
    unittest.main()
