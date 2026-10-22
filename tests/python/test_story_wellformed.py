"""Unit tests for templates/tools/lint/story-wellformed.py, the story lint.

Each fixture under tests/fixtures/lint/ is a tiny project with a model/
tree. The directory named after a finding code holds stories that draw
that finding and a story ending in `_Clean` that does not, its passing
twin. A test lints the fixture and compares the findings as
(path, line, code) triples in output order, so the triple list fixes
both what is reported and what is not. The line numbers were read off
the fixture files by hand.

The lint is tested in two ways: lint_paths() in process, and the
command line as a subprocess, the way the pre-commit hook runs it.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import contextlib
import importlib.util
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LINT_DIR = os.path.join(REPO, "templates", "tools", "lint")
LINT = os.path.join(LINT_DIR, "story-wellformed.py")
FIXTURES = os.path.join(REPO, "tests", "fixtures", "lint")
CORPUS = os.path.join(REPO, "tests", "fixtures", "stories")

# The lint ships as a loose script, so it is loaded from its file. No
# bytecode is written beside it, because the directory is mirrored byte
# for byte into the demo.
sys.dont_write_bytecode = True
_SPEC = importlib.util.spec_from_file_location("story_wellformed", LINT)
story_wellformed = importlib.util.module_from_spec(_SPEC)
sys.modules[_SPEC.name] = story_wellformed
_SPEC.loader.exec_module(story_wellformed)

STK = "model/core/stories/stakeholder/"
SYSML = STK + "stakeholder-stories.sysml"


def triples(findings):
    return [(finding.path, finding.line, finding.code)
            for finding in findings]


def lint(fixture, only="gherkin", paths=("model",)):
    """Lint a fixture project in process, paths relative to its root."""
    return triples(story_wellformed.lint_paths(
        list(paths), only, Path(FIXTURES) / fixture))


def lint_stories(fixture, stories, only="gherkin", paths=("model",)):
    """Lint a fixture project in process with the story-side findings
    restricted to `stories`, as --stories does."""
    return triples(story_wellformed.lint_paths(
        list(paths), only, Path(FIXTURES) / fixture, stories=stories))


def run_cli(args, cwd, lint=LINT):
    return subprocess.run(
        [sys.executable, lint] + list(args), cwd=cwd,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True, check=False)


class ScratchCopy:
    """A fixture copied into a temporary directory, removed on exit."""

    def __init__(self, fixture):
        self.fixture = fixture

    def __enter__(self):
        self.scratch = tempfile.mkdtemp(prefix="vse-lint-test-")
        self.root = os.path.join(self.scratch, "project")
        shutil.copytree(os.path.join(FIXTURES, self.fixture), self.root)
        return self.root

    def __exit__(self, *exc):
        shutil.rmtree(self.scratch, ignore_errors=True)


class CleanTests(unittest.TestCase):
    def test_clean_project_has_no_findings(self):
        # Both rule sets, a library that defines UserStory, a #derive
        # story typed by VSE_Library::UserStory, criteria reached by name,
        # by acceptance and by story, a satisfied story with scenarios,
        # and template files whose names start with _.
        self.assertEqual(lint("clean", None), [])


class StorySideTests(unittest.TestCase):
    def test_S1_missing_feature(self):
        # US_111 has no feature file, US_112's feature carries another
        # story's tag (which is also F4), US_113 is the twin. The feature
        # file of US_114 is empty, and that of US_115 holds comments and
        # blank lines only, so neither holds a Feature. US_114 is ready,
        # so it also draws the S8 for a ready story with no scenario.
        # US_115 is backlog but satisfied, so it draws the S8 for a
        # satisfy naming a story with no scenarios.
        self.assertEqual(lint("S1"), [
            (STK + "US_112_WrongTag.feature", 2, "F4"),
            (SYSML, 4, "S1"),
            (SYSML, 20, "S1"),
            (SYSML, 52, "S1"),
            (SYSML, 52, "S8"),
            (SYSML, 68, "S1"),
            (SYSML, 68, "S8"),
        ])

    def test_S1_says_the_feature_file_holds_no_feature(self):
        findings = story_wellformed.lint_paths(
            ["model"], "gherkin", Path(FIXTURES) / "S1")
        messages = {finding.message for finding in findings
                    if finding.code == "S1"}
        for name in ("US_114_EmptyFeature", "US_115_CommentsOnly"):
            with self.subTest(story=name):
                self.assertIn(
                    "{0}.feature holds no Feature. Write the Feature, "
                    "tagged @{0}".format(name),
                    " ".join(message for message in messages
                             if name in message))

    def test_S1_clean(self):
        self.assertEqual(lint("clean"), [])

    def test_S2_two_features_for_one_story(self):
        # The copy is tagged @US_121_TwoFeatures but named otherwise.
        self.assertEqual(lint("S2"), [
            (STK + "US_121_TwoFeaturesCopy.feature", 2, "F4"),
            (SYSML, 4, "S2"),
        ])

    def test_S3_legacy_prose(self):
        # Prose in `requirement :>> acceptance`, in the pre-4.0
        # `requirement acceptance[1]`, and beside a named criterion. The
        # finding sits on the doc line.
        self.assertEqual(lint("S3"), [
            (SYSML, 14, "S3"),
            (SYSML, 28, "S3"),
            (SYSML, 42, "S3"),
        ])

    def test_S4_criterion_without_scenario(self):
        # readingUnit has no @AC_readingUnit scenario. The finding sits on
        # the criterion line.
        self.assertEqual(lint("S4"), [(SYSML, 17, "S4")])

    def test_S5_tag_without_criterion(self):
        # The criterion of US_153 carries a short name, <'AC1'>, before
        # its name, and its tag still finds it.
        self.assertEqual(lint("S5"), [
            (STK + "US_151_ExtraTag.feature", 14, "S5"),
        ])

    def test_S6_narrative_mismatch(self):
        # Role, capability and benefit each differ once. The twins use a
        # two-word role, "I want" without "to", "As an" with a capital
        # role, and runs of spaces on either side.
        self.assertEqual(lint("S6"), [
            (STK + "US_161_OtherRole.feature", 4, "S6"),
            (STK + "US_162_OtherCapability.feature", 5, "S6"),
            (STK + "US_163_OtherBenefit.feature", 6, "S6"),
        ])

    def test_S7_sibling_and_typed_criteria(self):
        # US_174's typed criterion carries a short name before its name.
        self.assertEqual(lint("S7"), [
            (SYSML, 13, "S7"),
            (SYSML, 28, "S7"),
            (SYSML, 60, "S7"),
        ])

    def test_S8_story_ordering(self):
        # US_181: ready with no tagged scenario. US_182: inProgress with
        # readingUnit reached by no case. US_186 and US_189: a satisfy
        # for a story with no scenarios (US_189 has no feature file at
        # all). US_183, US_184 and US_185 are reached by name, by
        # acceptance and by story. US_187 is backlog, US_188 is satisfied
        # and has a scenario. US_190 is reached by a case written on one
        # line, and each criterion of US_191 by one of two cases that
        # share a line.
        self.assertEqual(lint("S8"), [
            (SYSML, 4, "S8"),
            (SYSML, 27, "S8"),
            (SYSML, 81, "S8"),
            (SYSML, 117, "S1"),
            (SYSML, 117, "S8"),
        ])

    def test_S8_reads_cases_from_the_model_root(self):
        # Only the stories directory is named, and the cases and the
        # satisfy relationships elsewhere under model/ still count.
        self.assertEqual(lint("S8", paths=[STK]), [
            (SYSML, 4, "S8"),
            (SYSML, 27, "S8"),
            (SYSML, 81, "S8"),
            (SYSML, 117, "S1"),
            (SYSML, 117, "S8"),
        ])

    def test_S8_strictest_row_when_status_unreadable_or_unranked(self):
        # A story whose status cannot be read, or whose status §11.4
        # does not rank (blocked, which the project's storymeta allows),
        # is held to the inProgress and done row. US_511 has no tagged
        # scenario, and the criteria of US_512 and US_513 are reached by
        # no case. US_514 and US_515_Clean meet the row.
        self.assertEqual(lint("status"), [
            (SYSML, 4, "S8"),
            (SYSML, 24, "S8"),
            (SYSML, 40, "S8"),
        ])

    def test_S8_says_the_status_was_unreadable(self):
        findings = story_wellformed.lint_paths(
            ["model"], "gherkin", Path(FIXTURES) / "status")

        def messages(sid):
            return " ".join(finding.message for finding in findings
                            if sid in finding.message)

        self.assertIn("status cannot be read",
                      messages("US_511_NoStatusNoScenario"))
        self.assertIn("status cannot be read",
                      messages("US_512_NoStatusUncovered"))
        self.assertIn("does not rank its status blocked",
                      messages("US_513_UnrankedStatusUncovered"))

    def test_S9_unreadable_story_declarations(self):
        # A definition, a subsetting usage and a usage typed by another
        # library's UserStory. The other library's own definition of
        # UserStory is not a finding, and neither is US_195, typed by a
        # member of UserStory, which is not a story either.
        self.assertEqual(lint("S9"), [
            (SYSML, 8, "S9"),
            (SYSML, 12, "S9"),
            (SYSML, 16, "S9"),
        ])

    def test_S9_story_file_that_is_not_utf8(self):
        with ScratchCopy("register") as root:
            path = os.path.join(root, SYSML)
            with open(path, "rb") as handle:
                lines = handle.read().split(b"\n")
            lines[5] += b" \xff"
            with open(path, "wb") as handle:
                handle.write(b"\n".join(lines))
            findings = story_wellformed.lint_paths(["model"], None,
                                                   Path(root))
        self.assertEqual(triples(findings), [(SYSML, 6, "S9")])

    def test_S9_only_under_the_gherkin_rule_set(self):
        # A finding carries one disposition, so a model file that is not
        # UTF-8 is the gherkin gate's alone.
        with ScratchCopy("register") as root:
            path = os.path.join(root, SYSML)
            with open(path, "ab") as handle:
                handle.write(b"// \xff\n")
            findings = {
                only: triples(story_wellformed.lint_paths(
                    ["model"], only, Path(root)))
                for only in ("wellformed", "gherkin")}
        self.assertEqual(findings, {
            "wellformed": [],
            "gherkin": [(SYSML, 68, "S9")],
        })

    def test_S9_story_file_that_cannot_be_read(self):
        # A dangling link named like a story file cannot be read. The
        # gherkin rule set reports it, and the wellformed one does not.
        with ScratchCopy("register") as root:
            os.symlink("no-such-target.sysml",
                       os.path.join(root, STK, "dangling.sysml"))
            findings = {
                only: triples(story_wellformed.lint_paths(
                    ["model"], only, Path(root)))
                for only in ("wellformed", "gherkin", None)}
        dangling = (STK + "dangling.sysml", 1, "S9")
        missing_feature = (SYSML, 36, "S1")
        self.assertEqual(findings, {
            "wellformed": [],
            "gherkin": [dangling, missing_feature],
            None: [dangling, missing_feature],
        })

    @unittest.skipUnless(hasattr(os, "mkfifo"), "needs named pipes")
    def test_special_files_are_never_opened(self):
        # A named pipe, or a link to one, named like a model or feature
        # file would block a read for ever, so a directory search keeps
        # regular files and links alone, and a link only when it does
        # not lead to something else that exists. The pipes sit in a
        # stories directory and, outside the paths named, in the model
        # root that S8 reads. The lint runs as the hook runs it, with a
        # time limit, and finds what it finds without the pipes.
        def run(root, only, path):
            try:
                result = subprocess.run(
                    [sys.executable, LINT, "--only", only, "--format",
                     "json", path], cwd=root,
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    universal_newlines=True, check=False, timeout=15)
            except subprocess.TimeoutExpired:
                self.fail("the lint blocked on a named pipe "
                          "(--only {} {})".format(only, path))
            return result.returncode, result.stdout, result.stderr

        runs = [(only, path) for only in ("wellformed", "gherkin", "syntax")
                for path in ("model", STK)]
        with ScratchCopy("register") as root:
            before = {key: run(root, *key) for key in runs}
            other = os.path.join(root, "model", "core", "domain")
            os.makedirs(other)
            for directory in (os.path.join(root, STK), other):
                os.mkfifo(os.path.join(directory, "pipe.sysml"))
                os.mkfifo(os.path.join(directory, "pipe.feature"))
                os.symlink("pipe.sysml",
                           os.path.join(directory, "pipe-link.sysml"))
            after = {key: run(root, *key) for key in runs}
        self.assertEqual(after, before)

    def test_file_reached_through_two_directories_reported_once(self):
        # A link in a second stories directory reaches the same story
        # file and feature file. Each finding about them is reported
        # once, as when the first directory is linted alone.
        team = "model/core/stories/team/"
        with ScratchCopy("register") as root:
            with open(os.path.join(root, SYSML), "ab") as handle:
                handle.write(b"// \xff\n")
            orphan = os.path.join(root, STK, "Orphan.feature")
            with open(orphan, "w") as handle:
                handle.write("Feature: Orphan\n  Scenario: Nothing\n"
                             "    Given nothing\n")
            alone = triples(story_wellformed.lint_paths(
                [STK], "gherkin", Path(root)))
            os.mkdir(os.path.join(root, team))
            for name in ("stakeholder-stories.sysml", "Orphan.feature"):
                os.symlink(os.path.join("..", "stakeholder", name),
                           os.path.join(root, team, name))
            both = triples(story_wellformed.lint_paths(
                ["model"], "gherkin", Path(root)))
        self.assertIn((SYSML, 68, "S9"), alone)
        self.assertIn((STK + "Orphan.feature", 1, "F3"), alone)
        self.assertEqual(both, alone)

    def test_stories_outside_a_stories_directory_are_not_checked(self):
        # The stories of model/core/requirements/ draw nothing: not S1
        # for US_301 (no feature file), not S4, S5 or S8 for US_302
        # (whose feature file draws F10 alone), and not S9 for the
        # legacy definition US_303. The story in the stories directory
        # is still checked.
        self.assertEqual(lint("outside"), [
            ("model/core/requirements/US_302_WithFeature.feature", 1,
             "F10"),
            (SYSML, 4, "S1"),
        ])

    def test_stories_outside_when_their_directory_is_named(self):
        # The pre-commit hook names a changed feature file outside a
        # stories directory as itself, so its directory is checked.
        self.assertEqual(
            lint("outside",
                 paths=["model/core/requirements/US_302_WithFeature.feature"]),
            [("model/core/requirements/US_302_WithFeature.feature", 1,
              "F10")])

    def test_F10_says_to_move_the_story_as_well(self):
        # A story declared outside a stories directory is not checked,
        # so the advice cannot be to leave the feature file beside it.
        findings = story_wellformed.lint_paths(
            ["model"], "gherkin", Path(FIXTURES) / "outside")
        message = next(finding.message for finding in findings
                       if finding.code == "F10")
        self.assertIn("move the story there first if it is declared "
                      "elsewhere", message)

    def test_S8_qualified_story_identifier_in_lower_case(self):
        # `verify P::story_1;` reaches the story story_1, whose
        # identifier starts in lower case, rather than a story P.
        with tempfile.TemporaryDirectory() as root:
            stories = os.path.join(root, STK)
            os.makedirs(stories)
            with open(os.path.join(stories, "story_1.feature"), "w",
                      encoding="utf-8") as handle:
                handle.write("@story_1\n"
                             "Feature: See the first reading\n"
                             "  As an operator\n"
                             "  I want to see the first reading\n"
                             "  So that the device is known to work\n"
                             "\n"
                             "  @AC_firstReading\n"
                             "  Scenario: The first reading appears\n"
                             "    When it takes a reading\n"
                             "    Then the reading is shown\n")
            with open(os.path.join(stories, "stories.sysml"), "w",
                      encoding="utf-8") as handle:
                handle.write(
                    "package P {\n"
                    "    requirement story_1 : UserStory {\n"
                    "        @StoryMeta { status = StoryStatus::inProgress; }\n"
                    "        requirement :>> acceptance {\n"
                    "            requirement firstReading { doc /* x */ }\n"
                    "        }\n"
                    "    }\n"
                    "}\n")
            cases = os.path.join(root, "model", "core", "cases.sysml")
            with open(cases, "w", encoding="utf-8") as handle:
                handle.write("package V {\n"
                             "    verification def VAL_1 {\n"
                             "        objective { verify P::story_1; }\n"
                             "    }\n"
                             "}\n")
            findings = story_wellformed.lint_paths(["model"], "gherkin",
                                                   Path(root))
        self.assertEqual(triples(findings), [])

    def test_register_file_four_stories(self):
        # Four stories in one register file, each paired with its own
        # feature file. Only the third has none.
        self.assertEqual(lint("register"), [(SYSML, 36, "S1")])

    def test_story_identification_agrees_with_corpus(self):
        # The shared corpus also drives the in-session scanner in
        # hooks/lib/test-first.sh, so the two agree on what a story is.
        names = sorted(name for name in os.listdir(CORPUS)
                       if name.endswith(".sysml"))
        self.assertTrue(names)
        for name in names:
            with self.subTest(corpus=name):
                with open(os.path.join(CORPUS, name),
                          encoding="utf-8") as handle:
                    stories = story_wellformed.read_stories(
                        handle.read()).stories
                with open(os.path.join(CORPUS, name[:-6] + ".ids"),
                          encoding="utf-8") as handle:
                    expected = handle.read().split()
                self.assertEqual(
                    [story.identifier for story in stories], expected)

    def test_corpus_declarations_outside_the_canonical_form(self):
        with open(os.path.join(CORPUS, "requirement-def.sysml"),
                  encoding="utf-8") as handle:
            scan = story_wellformed.read_stories(handle.read())
        self.assertEqual([line for line, _text in scan.unreadable],
                         [12, 16, 20])


class StoryScopeTests(unittest.TestCase):
    """--stories restricts the story-side findings to the stories it
    names, which is how the commit gate checks only the stories a change
    touches. File-side findings (F1 to F10, and S9 for a .sysml file)
    follow the files named or found, with or without the option."""

    def test_story_side_findings_only_for_the_stories_named(self):
        # Only US_403 of the register has no feature file.
        self.assertEqual(lint_stories("register", ["US_403_Third"]),
                         [(SYSML, 36, "S1")])
        self.assertEqual(lint_stories("register", ["US_401_First"]), [])
        self.assertEqual(lint_stories("register", []), [])

    def test_S2_follows_the_story(self):
        # The copy's F4 is a finding about the copy, so it stays. S2 is
        # about US_121, so it is reported only when US_121 is named.
        copy = (STK + "US_121_TwoFeaturesCopy.feature", 2, "F4")
        self.assertEqual(lint_stories("S2", ["US_122_Clean"]), [copy])
        self.assertEqual(lint_stories("S2", ["US_121_TwoFeatures"]),
                         [copy, (SYSML, 4, "S2")])

    def test_feature_findings_are_not_restricted(self):
        # F3 for the three feature files, and no S1 for the two stories
        # whose feature file carries no usable tag.
        self.assertEqual(lint_stories("F3", []), [
            (STK + "US_221_TwoTags.feature", 3, "F3"),
            (STK + "US_222_NoTag.feature", 2, "F3"),
            (STK + "US_223_InvalidTag.feature", 2, "F3"),
        ])

    def test_S8_still_reads_cases_outside_the_paths_named(self):
        # Only one feature file is named. A case under
        # verification-validation/ reaches US_183 by name, and no case
        # reaches the criterion readingUnit of US_182.
        self.assertEqual(lint_stories(
            "S8", ["US_182_OneCriterionUncovered", "US_183_CoveredByName"],
            paths=[STK + "US_183_CoveredByName.feature"]),
            [(SYSML, 27, "S8")])

    def test_S9_only_for_the_story_files_named_or_found(self):
        # The story file is found by the directory search, so its
        # unreadable declarations are reported whatever the stories
        # named. Naming the feature file alone names no story file.
        found = [(SYSML, 8, "S9"), (SYSML, 12, "S9"), (SYSML, 16, "S9")]
        self.assertEqual(lint_stories("S9", []), found)
        feature = [STK + "US_194_Clean.feature"]
        self.assertEqual(lint_stories("S9", ["US_194_Clean"], paths=feature),
                         [])
        self.assertEqual(lint("S9", paths=feature), [])

    def test_feature_findings_only_for_the_feature_files_named_or_found(self):
        # A feature file beside the story file, but not named, draws no
        # finding of its own. The stories of the directory are still
        # paired with their feature files.
        with ScratchCopy("register") as root:
            with open(os.path.join(root, STK, "Orphan.feature"), "w",
                      encoding="utf-8") as handle:
                handle.write("Feature: Orphan\n"
                             "  As an operator\n"
                             "  I want to see nothing\n"
                             "  So that nothing happens\n"
                             "\n"
                             "  @AC_nothing\n"
                             "  Scenario: Nothing\n"
                             "    Given nothing\n"
                             "    When nothing is done\n"
                             "    Then nothing happens\n")
            named = triples(story_wellformed.lint_paths(
                [SYSML], "gherkin", Path(root)))
            searched = triples(story_wellformed.lint_paths(
                [STK], "gherkin", Path(root)))
        self.assertEqual(named, [(SYSML, 36, "S1")])
        self.assertEqual(searched, [(STK + "Orphan.feature", 1, "F3"),
                                    (SYSML, 36, "S1")])

    def test_wellformed_findings_only_for_the_stories_named(self):
        self.assertEqual(
            lint_stories("W10", ["US_342_UnknownStatus"], "wellformed"),
            [(SYSML, 15, "W10")])
        self.assertEqual(lint_stories("W10", [], "wellformed"), [])

    def test_wellformed_finds_a_named_story_through_its_feature_file(self):
        # Naming only the story's feature file checks the story, which is
        # declared in a story file of the same directory.
        with ScratchCopy("W10") as root:
            feature = os.path.join(STK, "US_342_UnknownStatus.feature")
            with open(os.path.join(root, feature), "w",
                      encoding="utf-8") as handle:
                handle.write("@US_342_UnknownStatus\nFeature: Reading\n")
            findings = triples(story_wellformed.lint_paths(
                [feature], "wellformed", Path(root),
                stories=["US_342_UnknownStatus"]))
        self.assertEqual(findings, [(SYSML, 15, "W10")])


class FeatureSideTests(unittest.TestCase):
    def test_F1_parse_error(self):
        self.assertEqual(lint("F1"), [
            (STK + "US_201_Unparsable.feature", 1, "F1"),
        ])

    def test_F1_feature_file_that_is_not_utf8(self):
        with ScratchCopy("F1") as root:
            path = os.path.join(root, STK, "US_202_Clean.feature")
            with open(path, "rb") as handle:
                lines = handle.read().split(b"\n")
            lines[4] += b" \xff"
            with open(path, "wb") as handle:
                handle.write(b"\n".join(lines))
            findings = story_wellformed.lint_paths(["model"], "gherkin",
                                                   Path(root))
        self.assertEqual(triples(findings), [
            (STK + "US_201_Unparsable.feature", 1, "F1"),
            (STK + "US_202_Clean.feature", 5, "F1"),
        ])

    def test_F2_language(self):
        self.assertEqual(lint("F2"), [
            (STK + "US_211_Norwegian.feature", 1, "F2"),
        ])

    def test_F3_story_tag(self):
        # Two tags, no tag (also S1) and a tag that is not a valid story
        # identifier (also S1).
        self.assertEqual(lint("F3"), [
            (STK + "US_221_TwoTags.feature", 3, "F3"),
            (STK + "US_222_NoTag.feature", 2, "F3"),
            (STK + "US_223_InvalidTag.feature", 2, "F3"),
            (SYSML, 20, "S1"),
            (SYSML, 36, "S1"),
        ])

    def test_F4_file_name(self):
        self.assertEqual(lint("F4"), [
            (STK + "US_231_Renamed.feature", 2, "F4"),
            (SYSML, 4, "S1"),
        ])

    def test_F5_criterion_tags(self):
        # Missing, repeated, not lowerCamelCase, and used twice. A @wip
        # tag beside a criterion tag is allowed. US_243 carries a
        # criterion tag on its Feature (also F3, a second tag), its Rule
        # and an Examples block, none of which states a criterion.
        feature = STK + "US_241_ScenarioTags.feature"
        misplaced = STK + "US_243_MisplacedTags.feature"
        self.assertEqual(lint("F5"), [
            (feature, 14, "F5"),
            (feature, 19, "F5"),
            (feature, 25, "F5"),
            (feature, 31, "F5"),
            (misplaced, 2, "F5"),
            (misplaced, 3, "F3"),
            (misplaced, 8, "F5"),
            (misplaced, 17, "F5"),
        ])

    def test_F5_names_where_the_misplaced_tag_sits(self):
        findings = story_wellformed.lint_paths(
            ["model"], "gherkin", Path(FIXTURES) / "F5")
        messages = [finding.message for finding in findings
                    if finding.path.endswith("US_243_MisplacedTags.feature")
                    and finding.code == "F5"]
        self.assertEqual(len(messages), 3, messages)
        for message, tag, owner in zip(
                messages, ("@AC_onFeature", "@AC_onRule", "@AC_onExamples"),
                ("A Feature", "A Rule", "An Examples block")):
            with self.subTest(tag=tag):
                self.assertIn(tag, message)
                self.assertIn("{} states no criterion of its own".format(
                    owner), message)

    def test_F6_narrative_order(self):
        # No narrative, the lines out of order, and other text first. The
        # twin has a further description line after the three.
        self.assertEqual(lint("F6"), [
            (STK + "US_251_NoNarrative.feature", 3, "F6"),
            (STK + "US_252_OutOfOrder.feature", 4, "F6"),
            (STK + "US_253_TextFirst.feature", 4, "F6"),
        ])

    def test_F7_background(self):
        self.assertEqual(lint("F7"), [
            (STK + "US_261_LateBackground.feature", 14, "F7"),
        ])

    def test_F8_step_order(self):
        self.assertEqual(lint("F8"), [
            (STK + "US_271_ThenFirst.feature", 12, "F8"),
        ])

    def test_F9_outline_examples(self):
        self.assertEqual(lint("F9"), [
            (STK + "US_281_NoExamples.feature", 9, "F9"),
        ])

    def test_F10_outside_stories(self):
        self.assertEqual(lint("F10"), [
            ("model/core/requirements/US_291_Misplaced.feature", 1, "F10"),
        ])


class WellformedTests(unittest.TestCase):
    def test_W2_subject(self):
        # No subject, two subjects, the subject after the role, and an
        # untyped subject.
        self.assertEqual(lint("W2", "wellformed"), [
            (SYSML, 4, "W2"),
            (SYSML, 17, "W2"),
            (SYSML, 28, "W2"),
            (SYSML, 37, "W2"),
        ])

    def test_W3_role(self):
        # No role at ready, two roles, and an untyped role at
        # inProgress. A backlog story may have no role yet.
        self.assertEqual(lint("W3", "wellformed"), [
            (SYSML, 4, "W3"),
            (SYSML, 18, "W3"),
            (SYSML, 28, "W3"),
        ])

    def test_W3_unreadable_status_counts_as_past_backlog(self):
        # W3 and S8 agree that any status other than backlog, an
        # unreadable one included, is past backlog. US_514 has no status
        # and no role.
        self.assertEqual(lint("status", "wellformed"), [
            (SYSML, 5, "W10"),
            (SYSML, 15, "W10"),
            (SYSML, 46, "W3"),
            (SYSML, 47, "W10"),
        ])

    def test_W6_narrative(self):
        self.assertEqual(lint("W6", "wellformed"), [
            (SYSML, 4, "W6"),
            (SYSML, 13, "W6"),
        ])

    def test_W9_storymeta_form(self):
        # A legacy doc comment in place of @StoryMeta, and two
        # unqualified enumeration values on one line.
        self.assertEqual(lint("W9", "wellformed"), [
            (SYSML, 4, "W9"),
            (SYSML, 15, "W9"),
            (SYSML, 15, "W9"),
        ])

    def test_W10_storymeta_fields_from_config(self):
        # The config lists points, priority and status (as a block list)
        # and the four statuses. Points missing at ready, an unknown
        # status, and no status at all. A backlog story need not carry
        # the other fields yet. US_346 lacks both its status and points,
        # and only the missing status is reported.
        self.assertEqual(lint("W10", "wellformed"), [
            (SYSML, 5, "W10"),
            (SYSML, 15, "W10"),
            (SYSML, 35, "W10"),
            (SYSML, 55, "W10"),
        ])

    def test_W10_defaults_without_config(self):
        # Without .iso-config.yaml only status is required and the four
        # statuses of section 1.5 are valid.
        with ScratchCopy("W10") as root:
            os.remove(os.path.join(root, ".iso-config.yaml"))
            findings = story_wellformed.lint_paths(["model"], "wellformed",
                                                   Path(root))
        self.assertEqual(triples(findings), [
            (SYSML, 15, "W10"),
            (SYSML, 35, "W10"),
            (SYSML, 55, "W10"),
        ])


class StatementTests(unittest.TestCase):
    def test_bare_block_starts_at_its_brace(self):
        # A block with no words before its `{` starts on the brace's
        # line, not on the line of the statement before it.
        statements = story_wellformed._statements("a;\n\n{\n}\n")
        self.assertEqual(
            [(statement.words, statement.line) for statement in statements],
            [(["a"], 1), ([], 3)])


class CompactFormattingTests(unittest.TestCase):
    def test_statements_on_one_line_are_read(self):
        # US_501, US_502 and US_504_Clean are each written on one line,
        # and US_503 has two narrative attributes on one line. US_501
        # lacks only its benefit and US_502's narrative names another
        # role. Nothing else is reported: the status, role, capability
        # (with an escaped quotation mark) and benefit of each story are
        # all read.
        self.assertEqual(lint("compact", None), [
            (STK + "US_502_OtherRole.feature", 4, "S6"),
            (SYSML, 4, "W6"),
        ])


class ModeTests(unittest.TestCase):
    def test_only_syntax_skips_story_rules(self):
        self.assertEqual(lint("S1", "syntax"), [])
        self.assertEqual(lint("F3", "syntax"), [])
        self.assertEqual(lint("F5", "syntax"), [])
        self.assertEqual(lint("F10", "syntax"), [])
        self.assertEqual(lint("F8", "syntax"), [
            (STK + "US_271_ThenFirst.feature", 12, "F8"),
        ])

    def test_only_wellformed_skips_gherkin_rules(self):
        self.assertEqual(lint("S1", "wellformed"), [])

    def test_only_gherkin_skips_wellformed_rules(self):
        codes = {code for _path, _line, code in lint("W2", "gherkin")}
        self.assertEqual(codes, {"S1"})

    def test_no_only_runs_both(self):
        self.assertEqual(lint("W6", None), [
            (SYSML, 4, "S1"),
            (SYSML, 4, "W6"),
            (SYSML, 13, "S1"),
            (SYSML, 13, "W6"),
            (SYSML, 22, "S1"),
        ])

    def test_findings_carry_a_section_reference(self):
        for fixture in ("S1", "S3", "S6", "S8", "S9", "F3", "F5", "F6",
                        "F10", "W2", "W9", "W10"):
            findings = story_wellformed.lint_paths(
                ["model"], None, Path(FIXTURES) / fixture)
            self.assertTrue(findings, fixture)
            for finding in findings:
                with self.subTest(fixture=fixture, finding=finding):
                    self.assertTrue(finding.ref.startswith("§"))
                    if finding.code.startswith("S"):
                        self.assertRegex(finding.message, r"\bUS_\d+_")


class CommandLineTests(unittest.TestCase):
    def test_exit_codes(self):
        clean = os.path.join(FIXTURES, "clean")
        self.assertEqual(run_cli(["model"], clean).returncode, 0)
        self.assertEqual(
            run_cli(["model"], os.path.join(FIXTURES, "S1")).returncode, 1)
        missing = run_cli(["no-such-path"], clean)
        self.assertEqual(missing.returncode, 2)
        self.assertIn("no-such-path", missing.stderr)
        self.assertEqual(run_cli(["--only", "everything", "model"],
                                 clean).returncode, 2)
        self.assertEqual(run_cli([], clean).returncode, 2)

    def test_stories_option(self):
        # A comma-separated list, given more than once, or empty, which
        # names no story.
        register = os.path.join(FIXTURES, "register")
        named = run_cli(["--only", "gherkin", "--stories",
                         "US_401_First,US_402_Second", "--stories",
                         "US_404_Fourth", "model"], register)
        self.assertEqual((named.returncode, named.stdout), (0, ""))
        third = run_cli(["--only", "gherkin", "--stories", "US_403_Third",
                         "model"], register)
        self.assertEqual(third.returncode, 1)
        self.assertIn(" S1 US_403_Third has no feature file", third.stdout)
        none = run_cli(["--only", "gherkin", "--stories=", "model"],
                       register)
        self.assertEqual((none.returncode, none.stdout), (0, ""))

    def test_stories_option_rejects_a_name_that_is_no_identifier(self):
        result = run_cli(["--stories", "US_401_First,US 402", "model"],
                         os.path.join(FIXTURES, "register"))
        self.assertEqual(result.returncode, 2)
        self.assertEqual(len(result.stderr.splitlines()), 1)
        self.assertIn("US 402", result.stderr)

    def test_text_format(self):
        result = run_cli(["model"], os.path.join(FIXTURES, "S4"))
        self.assertEqual(result.returncode, 1)
        lines = result.stdout.splitlines()
        self.assertEqual(len(lines), 1)
        self.assertRegex(
            lines[0],
            r"^model/core/stories/stakeholder/stakeholder-stories\.sysml:17:"
            r" S4 .*readingUnit.* \(§[0-9.]+(, §[0-9.]+)*\)$")

    def test_json_format(self):
        result = run_cli(["--format", "json", "model"],
                         os.path.join(FIXTURES, "S1"))
        self.assertEqual(result.returncode, 1)
        findings = json.loads(result.stdout)
        self.assertEqual(
            [(item["path"], item["line"], item["code"]) for item in findings],
            [
                (STK + "US_112_WrongTag.feature", 2, "F4"),
                (SYSML, 4, "S1"),
                (SYSML, 20, "S1"),
                (SYSML, 52, "S1"),
                (SYSML, 52, "S8"),
                (SYSML, 68, "S1"),
                (SYSML, 68, "S8"),
            ])
        for item in findings:
            self.assertEqual(sorted(item),
                             ["code", "line", "message", "path", "ref"])

    def test_json_format_clean(self):
        result = run_cli(["--format", "json", "model"],
                         os.path.join(FIXTURES, "clean"))
        self.assertEqual((result.returncode, json.loads(result.stdout)),
                         (0, []))

    def test_render_module_missing_exit_2(self):
        # The lint is installed beside tools/render/. Without it the lint
        # cannot read the model, and it says so instead of passing.
        with tempfile.TemporaryDirectory() as scratch:
            lint_copy = os.path.join(scratch, "tools", "lint")
            shutil.copytree(LINT_DIR, lint_copy,
                            ignore=shutil.ignore_patterns("__pycache__"))
            result = run_cli(
                ["model"], os.path.join(FIXTURES, "clean"),
                lint=os.path.join(lint_copy, "story-wellformed.py"))
        self.assertEqual(result.returncode, 2)
        self.assertIn("render", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_render_module_older_exit_2(self):
        # A tools/render/ left at an earlier release beside a newer
        # tools/lint/ imports cleanly but lacks Case.resolved, which the
        # lint calls. The stub reader is the current one without it. The
        # lint names the stale reader as the cause instead of failing on
        # an unexplained AttributeError.
        with open(os.path.join(REPO, "templates", "tools", "render",
                               "sysml_model.py"), encoding="utf-8") as handle:
            stale_reader = handle.read() + "\n\ndel Case.resolved\n"
        with tempfile.TemporaryDirectory() as scratch:
            tools = os.path.join(scratch, "tools")
            shutil.copytree(LINT_DIR, os.path.join(tools, "lint"),
                            ignore=shutil.ignore_patterns("__pycache__"))
            os.makedirs(os.path.join(tools, "render"))
            reader = os.path.join(tools, "render", "sysml_model.py")
            with open(reader, "w", encoding="utf-8") as handle:
                handle.write(stale_reader)
            result = run_cli(
                ["model"], os.path.join(FIXTURES, "clean"),
                lint=os.path.join(tools, "lint", "story-wellformed.py"))
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(len(result.stderr.splitlines()), 1, result.stderr)
        self.assertIn(
            "tools/render/sysml_model.py at {} is older than tools/lint/. "
            "Refresh tools/render/ from the same plugin version (re-run "
            "@attention-regime)".format(os.path.normpath(reader)),
            result.stderr)
        self.assertNotIn("AttributeError", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_os_error_exits_2_on_one_line(self):
        # The working directory is removed after the lint starts in it,
        # so the lint cannot resolve its paths. That is an environment
        # error: exit 2 and one line on standard error, not a traceback.
        scratch = tempfile.mkdtemp(prefix="vse-lint-test-")
        gone = os.path.join(scratch, "gone")
        os.mkdir(gone)
        try:
            result = subprocess.run(
                [sys.executable, LINT, "model"], cwd=gone,
                preexec_fn=lambda: os.rmdir(gone),
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                universal_newlines=True, check=False)
        finally:
            shutil.rmtree(scratch, ignore_errors=True)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(len(result.stderr.splitlines()), 1, result.stderr)
        self.assertIn("story-wellformed.py:", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_unexpected_error_exits_2_on_one_line(self):
        # No input is known to raise inside the lint, so a stand-in for
        # lint_paths raises the way a defect would.
        def defect(*_args):
            raise RuntimeError("a defect in the lint")

        # main() reconfigures standard output, so the test hands it a
        # stand-in rather than the test runner's own.
        stderr = io.StringIO()
        with mock.patch.object(story_wellformed, "lint_paths", defect), \
                mock.patch.object(sys, "stdout", io.StringIO()), \
                contextlib.redirect_stderr(stderr):
            code = story_wellformed.main(["model"])
        self.assertEqual(code, 2)
        self.assertEqual(len(stderr.getvalue().splitlines()), 1,
                         stderr.getvalue())
        self.assertIn("a defect in the lint", stderr.getvalue())

    def _assert_write_error(self, stdout):
        """Run the lint on findings with `stdout` as its output, both
        buffered, as by default, and unbuffered (PYTHONUNBUFFERED), and
        expect exit 2 with one line on standard error."""
        for unbuffered in (False, True):
            environment = dict(os.environ)
            environment.pop("PYTHONUNBUFFERED", None)
            if unbuffered:
                environment["PYTHONUNBUFFERED"] = "1"
            with self.subTest(unbuffered=unbuffered):
                result = subprocess.run(
                    [sys.executable, LINT, "model"],
                    cwd=os.path.join(FIXTURES, "S1"), env=environment,
                    stdout=stdout, stderr=subprocess.PIPE,
                    universal_newlines=True, check=False, timeout=60)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertEqual(len(result.stderr.splitlines()), 1,
                                 result.stderr)
                self.assertIn("story-wellformed.py: cannot write the "
                              "findings", result.stderr)

    def test_closed_output_exits_2_on_one_line(self):
        # The reader of the findings has gone, as when the output is
        # piped into head, so writing them fails with a broken pipe.
        read_end, write_end = os.pipe()
        os.close(read_end)
        try:
            self._assert_write_error(write_end)
        finally:
            os.close(write_end)

    @unittest.skipUnless(os.path.exists("/dev/full"), "needs /dev/full")
    def test_full_output_exits_2_on_one_line(self):
        # Every write to /dev/full fails as a full disk would.
        with open("/dev/full", "w") as full:
            self._assert_write_error(full)

    def test_gherkin_module_missing_exit_2(self):
        with tempfile.TemporaryDirectory() as scratch:
            tools = os.path.join(scratch, "tools")
            shutil.copytree(LINT_DIR, os.path.join(tools, "lint"),
                            ignore=shutil.ignore_patterns("__pycache__",
                                                          "gherkin.py"))
            shutil.copytree(os.path.join(REPO, "templates", "tools",
                                         "render"),
                            os.path.join(tools, "render"),
                            ignore=shutil.ignore_patterns("__pycache__"))
            result = run_cli(
                ["model"], os.path.join(FIXTURES, "clean"),
                lint=os.path.join(tools, "lint", "story-wellformed.py"))
        self.assertEqual(result.returncode, 2)
        self.assertIn("gherkin.py", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
