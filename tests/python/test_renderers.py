"""Unit tests for the renderers under templates/tools/render/.

sysml_model.py is the reader the three renderers share. These tests
cover how it splits a verify target into a story and a member, how it
pairs each acceptance criterion with its scenario in the story's
feature file, and how stakeholder-reqs-doc.py and system-reqs-doc.py
print a criterion, as a fenced gherkin block when the scenario is known
and as its doc text otherwise.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
RENDER = os.path.join(REPO, "templates", "tools", "render")

# The reader and the renderers ship as loose scripts, so the test puts
# their directory on the path and loads each renderer from its file. No
# bytecode is written there, because the directory is mirrored byte for
# byte into the demo.
sys.dont_write_bytecode = True
sys.path.insert(0, RENDER)

import sysml_model  # noqa: E402


def load_renderer(name):
    """Load a renderer script, whose file name is not a module name."""
    spec = importlib.util.spec_from_file_location(
        name[:-len(".py")].replace("-", "_"), os.path.join(RENDER, name))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


RENDERERS = (
    ("stakeholder", load_renderer("stakeholder-reqs-doc.py")),
    ("system", load_renderer("system-reqs-doc.py")),
)


def write(root, relative, text):
    """Write `text` to `relative` under `root` and return the path."""
    path = Path(root) / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


class SplitTargetTests(unittest.TestCase):
    def check(self, cases):
        for qualified, expected in cases:
            with self.subTest(qualified=qualified):
                self.assertEqual(sysml_model._split_target(qualified),
                                 expected)

    def test_split_target_deep_chain(self):
        self.check([
            ("US_001_SeeReadings.acceptance.SeeLatest",
             ("US_001_SeeReadings", "acceptance.SeeLatest")),
            ("US_001_SeeReadings.acceptance.latestReadingShown",
             ("US_001_SeeReadings", "acceptance.latestReadingShown")),
        ])

    def test_split_target_deep_chain_counts_as_acceptance_coverage(self):
        with tempfile.TemporaryDirectory() as root:
            path = write(root, "model/cases.sysml", (
                "package Cases {\n"
                "    verification def VC_001_Latest {\n"
                "        objective {\n"
                "            verify US_001_SeeReadings.acceptance.SeeLatest;\n"
                "        }\n"
                "    }\n"
                "}\n"))
            model = sysml_model.Model(project_root=Path(root),
                                      model_root="model")
            sysml_model.parse_file(Path(root), path, model)
        case = model.cases[0]
        self.assertEqual(case.targets(), ["US_001_SeeReadings"])
        self.assertTrue(case.covers_acceptance("US_001_SeeReadings"))

    def test_split_target_pkg_prefix(self):
        self.check([
            ("Stories::US_001_SeeReadings.acceptance.SeeLatest",
             ("US_001_SeeReadings", "acceptance.SeeLatest")),
            ("S::Alarms.Queue.US_9_Y.acceptance.AllCleared",
             ("US_9_Y", "acceptance.AllCleared")),
            ("StakeholderStories::US_001_SeeReadings.acceptance",
             ("US_001_SeeReadings", "acceptance")),
        ])

    def test_split_target_legacy_member(self):
        self.check([
            ("SYS_001_DashboardLatency::acceptance",
             ("SYS_001_DashboardLatency", "acceptance")),
            ("SYS_001_DashboardLatency::dashboardSla",
             ("SYS_001_DashboardLatency", "dashboardSla")),
            ("SYS_001_DashboardLatency.dashboardSla",
             ("SYS_001_DashboardLatency", "dashboardSla")),
            ("Stories::US_001_SeeReadings",
             ("US_001_SeeReadings", "")),
        ])


STORY_DIR = "model/core/stories/stakeholder/"

STORY = """\
package ExampleStories {
    private import VSE_Library::*;

    requirement US_901_Example : UserStory {
        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        requirement :>> acceptance {
            requirement firstReading {
                doc /* The first reading is shown. */
            }
            requirement latestReadingShown {
                doc /* The later reading is shown. */
            }
            requirement alarmRaised {
                doc /* An alarm is raised. */
            }
        }
    }
}
"""

# A Background, a second tag, a comment and a Rule around the scenarios,
# so that each scenario's text has to be cut out of the file at the right
# lines. alarmRaised has no scenario.
FEATURE = """\
# language: en
@US_901_Example
Feature: See the readings
  As an operator
  I want to see the readings
  So that the device is known to work

  Background:
    Given the device is installed

  @AC_firstReading @smoke
  Scenario: The first reading appears
    Given the device is switched on
    When it takes a reading
    Then the reading is shown

  # Readings over time
  Rule: A later reading replaces an earlier one

    @AC_latestReadingShown
    Scenario Outline: The later of two readings is shown
      Given readings <first> and <second> were taken
      When the operator opens the display
      Then the display reads <second>

      Examples:
        | first | second |
        | 1     | 2      |
"""

FIRST_READING = """\
@AC_firstReading @smoke
Scenario: The first reading appears
  Given the device is switched on
  When it takes a reading
  Then the reading is shown"""

LATEST_READING = """\
@AC_latestReadingShown
Scenario Outline: The later of two readings is shown
  Given readings <first> and <second> were taken
  When the operator opens the display
  Then the display reads <second>

  Examples:
    | first | second |
    | 1     | 2      |"""


def scenarios(model):
    """(criterion label, scenario) for every criterion of every story."""
    return [(acceptance.label, acceptance.scenario)
            for story in model.stories for acceptance in story.acceptances]


class ScenarioTests(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp(prefix="vse-render-test-")
        self.addCleanup(shutil.rmtree, self.root, ignore_errors=True)
        write(self.root, STORY_DIR + "stories.sysml", STORY)

    def test_scenario_attached_from_feature(self):
        write(self.root, STORY_DIR + "US_901_Example.feature", FEATURE)
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual(scenarios(model), [
            ("firstReading", FIRST_READING),
            ("latestReadingShown", LATEST_READING),
            ("alarmRaised", None),
        ])

    def test_scenario_ends_before_a_later_background(self):
        # A Background after the first scenario is finding F7 of the
        # structure check, not a parse error, so the file is still read.
        late = FEATURE.replace(
            "  Background:\n    Given the device is installed\n\n", ""
        ).replace(
            "  # Readings over time\n",
            "  Background:\n    Given the device is installed\n\n"
            "  # Readings over time\n")
        write(self.root, STORY_DIR + "US_901_Example.feature", late)
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual(scenarios(model)[0], ("firstReading", FIRST_READING))

    def test_first_scenario_with_a_tag_wins(self):
        # The story lint reports a tag that two scenarios share, and until
        # it is fixed the document shows the first of them.
        twice = FEATURE.replace("    @AC_latestReadingShown",
                                "    @AC_firstReading")
        write(self.root, STORY_DIR + "US_901_Example.feature", twice)
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual(scenarios(model)[0], ("firstReading", FIRST_READING))

    def test_scenario_empty_without_feature(self):
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual(scenarios(model), [
            ("firstReading", None),
            ("latestReadingShown", None),
            ("alarmRaised", None),
        ])

    def test_feature_in_another_directory_is_not_read(self):
        write(self.root, "model/core/stories/system/US_901_Example.feature",
              FEATURE)
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual([scenario for _label, scenario in scenarios(model)],
                         [None, None, None])

    def test_feature_that_does_not_parse_is_not_used(self):
        # A table row with one cell under a header of two is a parse
        # error (F1), so the lint would stop this file at commit time.
        broken = FEATURE.replace("        | 1     | 2      |",
                                 "        | 1 |")
        write(self.root, STORY_DIR + "US_901_Example.feature", broken)
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual([scenario for _label, scenario in scenarios(model)],
                         [None, None, None])

    def test_unreadable_feature_is_not_used(self):
        path = Path(self.root) / STORY_DIR / "US_901_Example.feature"
        path.write_bytes(FEATURE.encode("utf-8") + b"\xff\xfe\n")
        model = sysml_model.load_model(Path(self.root))
        self.assertEqual([scenario for _label, scenario in scenarios(model)],
                         [None, None, None])

    def installed_scenarios(self, lint=None, before=""):
        """The (label, scenario) pairs a fresh interpreter reads with a
        copy of sysml_model.py under tools/render/. `lint` is the text of
        tools/lint/gherkin.py beside it (None installs no tools/lint/),
        and `before` is code that runs before sysml_model is imported,
        with the tools directory in TOOLS."""
        write(self.root, STORY_DIR + "US_901_Example.feature", FEATURE)
        tools = tempfile.mkdtemp(prefix="vse-render-only-")
        self.addCleanup(shutil.rmtree, tools, ignore_errors=True)
        render = os.path.join(tools, "render")
        os.makedirs(render)
        shutil.copy(os.path.join(RENDER, "sysml_model.py"), render)
        if lint is not None:
            write(tools, "lint/gherkin.py", lint)
        code = (
            "import sys\n"
            "sys.dont_write_bytecode = True\n"
            "TOOLS = sys.argv[1]\n"
            + before +
            "sys.path.insert(0, TOOLS + '/render')\n"
            "import sysml_model\n"
            "model = sysml_model.load_model(sys.argv[2])\n"
            "print([(a.label, a.scenario) for s in model.stories"
            " for a in s.acceptances])\n")
        completed = subprocess.run(
            [sys.executable, "-I", "-c", code, tools, self.root],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True, check=False)
        self.assertEqual(completed.returncode, 0, completed.stderr)
        return completed.stdout

    def test_scenario_empty_without_lint(self):
        # An older install has tools/render/ but no tools/lint/, so the
        # reader has no Gherkin parser. It still reads the model.
        self.assertEqual(
            self.installed_scenarios(),
            "[('firstReading', None), ('latestReadingShown', None), "
            "('alarmRaised', None)]\n")

    def test_scenario_empty_when_the_sibling_parser_has_no_parse(self):
        # A tools/lint/gherkin.py that is not the shipped parser (an old
        # or broken copy without parse) leaves the doc text in place.
        self.assertEqual(
            self.installed_scenarios(lint="VERSION = 1\n"),
            "[('firstReading', None), ('latestReadingShown', None), "
            "('alarmRaised', None)]\n")

    def test_an_unrelated_gherkin_module_is_never_used(self):
        # The Cucumber package installs a top-level module named gherkin,
        # with no parse function. It sits first on the path and is
        # already imported, and the lint directory is on the path behind
        # it, as when the story lint imports the reader. The reader still
        # parses with the sibling ../lint/gherkin.py.
        with open(os.path.join(REPO, "templates", "tools", "lint",
                               "gherkin.py"), encoding="utf-8") as handle:
            parser = handle.read()
        fake = tempfile.mkdtemp(prefix="vse-fake-gherkin-")
        self.addCleanup(shutil.rmtree, fake, ignore_errors=True)
        write(fake, "gherkin/__init__.py", "VERSION = '29.0.0'\n")
        before = (
            "sys.path.insert(0, {!r})\n"
            "import gherkin\n"
            "sys.path.append(TOOLS + '/lint')\n").format(fake)
        self.assertEqual(
            self.installed_scenarios(lint=parser, before=before),
            repr([("firstReading", FIRST_READING),
                  ("latestReadingShown", LATEST_READING),
                  ("alarmRaised", None)]) + "\n")


def criterion(label, doc, scenario=None):
    return sysml_model.Acceptance(
        label=label, doc=sysml_model.DocBlock([doc]), scenario=scenario)


def render(renderer, kind, acceptances):
    """The document a renderer writes for one story of `kind`, ending in
    the newline that write_document adds."""
    story = sysml_model.Story(identifier="US_901_Example",
                              source=STORY_DIR + "stories.sysml", kind=kind,
                              acceptances=acceptances)
    model = sysml_model.Model(project_root=Path("."), model_root="model",
                              stories=[story])
    _path, text = renderer.render(model)
    return text if text.endswith("\n") else text + "\n"


class RenderTests(unittest.TestCase):
    def check(self, acceptances, expected, absent=None):
        for kind, renderer in RENDERERS:
            with self.subTest(renderer=kind):
                text = render(renderer, kind, acceptances)
                self.assertIn(expected, text)
                if absent is not None:
                    self.assertNotIn(absent, text)

    def test_render_fenced_gherkin_block(self):
        self.check([
            criterion("firstReading", "The first reading is shown.",
                      FIRST_READING),
            criterion("latestReadingShown", "The later reading is shown.",
                      LATEST_READING),
            criterion("alarmRaised", "An alarm is raised."),
        ], """\
**Acceptance criteria**

1. `firstReading`

   ```gherkin
   @AC_firstReading @smoke
   Scenario: The first reading appears
     Given the device is switched on
     When it takes a reading
     Then the reading is shown
   ```

2. `latestReadingShown`

   ```gherkin
   @AC_latestReadingShown
   Scenario Outline: The later of two readings is shown
     Given readings <first> and <second> were taken
     When the operator opens the display
     Then the display reads <second>

     Examples:
       | first | second |
       | 1     | 2      |
   ```

3. An alarm is raised.
""")

    def test_render_falls_back_to_doc(self):
        self.check([
            criterion("firstReading", "The first reading is shown."),
            criterion("alarmRaised", "An alarm is raised."),
        ], """\
**Acceptance criteria**

1. The first reading is shown.
2. An alarm is raised.
""", absent="```")

    def test_render_fence_outgrows_backticks_in_scenario(self):
        scenario = ("@AC_reportSent\n"
                    "Scenario: The report is sent\n"
                    "  Given a report\n"
                    "  When it is sent\n"
                    "  Then the body reads\n"
                    "    ```\n"
                    "    reading 1\n"
                    "    ```")
        self.check([criterion("reportSent", "The report is sent.", scenario)],
                   """\
1. `reportSent`

   ````gherkin
   @AC_reportSent
   Scenario: The report is sent
     Given a report
     When it is sent
     Then the body reads
       ```
       reading 1
       ```
   ````
""")

    def test_render_block_indented_under_a_wide_number(self):
        # The tenth item's content starts after "10. ", one column later
        # than after "9. ", and a block indented less leaves the list.
        acceptances = [criterion("c{}".format(number), "Text.")
                       for number in range(1, 10)]
        acceptances.append(criterion("c10", "Text.",
                                     "@AC_c10\nScenario: Ten"))
        self.check(acceptances, """\
9. Text.

10. `c10`

    ```gherkin
    @AC_c10
    Scenario: Ten
    ```
""")


if __name__ == "__main__":
    unittest.main()
