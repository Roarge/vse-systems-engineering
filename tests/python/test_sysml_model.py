"""Unit tests for templates/tools/render/sysml_model.py, the model reader.

The renderers and the story lint share this reader. These tests cover
the comment stripping that both rely on.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import os
import sys
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


if __name__ == "__main__":
    unittest.main()
