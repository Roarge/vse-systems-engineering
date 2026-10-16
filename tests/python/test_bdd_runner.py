"""Unit tests for tests/bdd/run.py, the stdlib runner for Gherkin scenarios.

Each test runs the runner as a subprocess against fixture features from
tests/fixtures/bdd/ and the fixture step definitions in
tests/fixtures/bdd/steps/. Those steps append to a log file named by the
BDD_FIXTURE_LOG environment variable, so a test can check which steps
and cleanups ran, and in which order.

Run from the repository root:

    python3 -m unittest discover -s tests/python -t . -v
"""

import os
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
RUN = os.path.join(REPO, "tests", "bdd", "run.py")
FIXTURES = os.path.join(REPO, "tests", "fixtures", "bdd")
STEPS = os.path.join(FIXTURES, "steps")


def feature(name):
    return os.path.join(FIXTURES, name)


def summary(passed, failed, undefined, skipped):
    return "bdd: {} passed, {} failed, {} undefined, {} skipped".format(
        passed, failed, undefined, skipped
    )


class RunnerTests(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.scratch = scratch.name
        self.log = os.path.join(self.scratch, "log.txt")

    def run_bdd(self, *args):
        """Run the runner with the fixture steps. Return (code, out, err)."""
        env = dict(os.environ, BDD_FIXTURE_LOG=self.log)
        completed = subprocess.run(
            [sys.executable, RUN, "--steps", STEPS] + list(args),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            env=env,
            cwd=REPO,
            check=False,
        )
        return completed.returncode, completed.stdout, completed.stderr

    def logged(self):
        if not os.path.exists(self.log):
            return []
        with open(self.log, encoding="utf-8") as handle:
            return handle.read().splitlines()

    def test_passing_scenario_exit_0(self):
        path = feature("passing.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn("PASS {}:4 Every step passes".format(path), lines)
        self.assertEqual(lines[-1], summary(1, 0, 0, 0))
        self.assertEqual(self.logged(), ["passing ran"])
        self.assertEqual(code, 0, out + err)

    def test_failing_assertion_exit_1_and_reports_line(self):
        path = feature("failing.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn("FAIL {}:3 An odd number is not even".format(path),
                      lines)
        self.assertIn(
            "  {}:6: failed: Then the number 3 is even".format(path), lines
        )
        self.assertIn("AssertionError: 3 is odd", out)
        # The failing step stops its scenario, but the next scenario runs.
        self.assertIn("PASS {}:9 A later scenario still runs".format(path),
                      lines)
        self.assertEqual(self.logged(), ["failing ran", "later scenario ran"])
        self.assertEqual(lines[-1], summary(1, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_undefined_step_counts_and_exit_1(self):
        path = feature("undefined.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn("UNDEFINED {}:3 A step nobody wrote".format(path),
                      lines)
        self.assertIn(
            "  {}:5: undefined: When an undefined step nobody wrote"
            .format(path), lines
        )
        self.assertEqual(self.logged(), [])
        self.assertEqual(lines[-1], summary(0, 0, 1, 0))
        self.assertEqual(code, 1, out + err)

    def test_pattern_must_match_the_whole_step(self):
        path = feature("full_match.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "UNDEFINED {}:3 Extra words after a defined step".format(path),
            lines,
        )
        self.assertIn(
            "UNDEFINED {}:8 Extra words before a defined step".format(path),
            lines,
        )
        self.assertEqual(self.logged(), [])
        self.assertEqual(lines[-1], summary(0, 0, 2, 0))
        self.assertEqual(code, 1, out + err)

    def test_ambiguous_step_fails(self):
        path = feature("ambiguous.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "FAIL {}:3 Two definitions match one step".format(path), lines
        )
        self.assertIn(
            "  {}:5: ambiguous: When the ambiguous step".format(path), lines
        )
        self.assertIn("'the ambiguous step'", out)
        self.assertIn("'the ambiguous .*'", out)
        self.assertEqual(self.logged(), [])
        self.assertEqual(lines[-1], summary(0, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_wip_skipped_by_default(self):
        wip = feature("wip.feature")
        wip_feature = feature("wip_feature.feature")
        code, out, err = self.run_bdd(wip, wip_feature)
        lines = out.splitlines()
        self.assertEqual(lines, [
            "PASS {}:3 A finished scenario".format(wip),
            "SKIP {}:9 An unfinished scenario".format(wip),
            "SKIP {}:17 A scenario inside the unfinished rule".format(wip),
            "SKIP {}:4 A scenario inside the unfinished feature"
            .format(wip_feature),
            summary(1, 0, 0, 3),
        ])
        self.assertEqual(self.logged(), ["finished"])
        self.assertEqual(code, 0, out + err)

    def test_wip_runs_with_flag(self):
        wip = feature("wip.feature")
        wip_feature = feature("wip_feature.feature")
        code, out, err = self.run_bdd("--include-wip", wip, wip_feature)
        lines = out.splitlines()
        self.assertEqual(lines, [
            "PASS {}:3 A finished scenario".format(wip),
            "PASS {}:9 An unfinished scenario".format(wip),
            "PASS {}:17 A scenario inside the unfinished rule".format(wip),
            "PASS {}:4 A scenario inside the unfinished feature"
            .format(wip_feature),
            summary(4, 0, 0, 0),
        ])
        self.assertEqual(self.logged(), [
            "finished", "unfinished scenario", "unfinished rule",
            "unfinished feature",
        ])
        self.assertEqual(code, 0, out + err)

    def test_outline_runs_each_row(self):
        path = feature("outline.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn("PASS {}:3 The number 2 is even".format(path), lines)
        self.assertIn("FAIL {}:3 The number 3 is even".format(path), lines)
        self.assertIn("PASS {}:3 The number 4 is even".format(path), lines)
        self.assertEqual(self.logged(), ["row 2", "row 3", "row 4"])
        self.assertEqual(lines[-1], summary(2, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_background_prepended(self):
        path = feature("background.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn("PASS {}:6 A scenario at feature level".format(path),
                      lines)
        self.assertIn("PASS {}:16 A scenario inside the rule".format(path),
                      lines)
        # The Rule Background runs after the Feature Background.
        self.assertEqual(self.logged(), [
            "feature background", "feature scenario",
            "feature background", "rule background", "rule scenario",
        ])
        self.assertEqual(lines[-1], summary(2, 0, 0, 0))
        self.assertEqual(code, 0, out + err)

    def test_each_scenario_gets_a_fresh_context(self):
        path = feature("context.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "PASS {}:8 The second scenario sees a fresh context".format(path),
            lines,
        )
        self.assertEqual(lines[-1], summary(2, 0, 0, 0))
        self.assertEqual(code, 0, out + err)

    def test_doc_string_and_table_reach_their_steps(self):
        path = feature("arguments.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "PASS {}:3 A doc string and a table reach their steps"
            .format(path), lines
        )
        self.assertEqual(code, 0, out + err)

    def test_cleanup_runs_after_failure(self):
        path = feature("cleanup.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "FAIL {}:3 Cleanups run after a failing step".format(path), lines
        )
        # Cleanups run after the failing step, last registered first.
        self.assertEqual(self.logged(), [
            "before the failure", "second cleanup", "first cleanup",
        ])
        self.assertEqual(code, 1, out + err)

    def test_cleanup_error_fails_the_scenario(self):
        path = feature("cleanup_error.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "FAIL {}:3 A cleanup that raises fails a passing scenario"
            .format(path), lines
        )
        self.assertIn("  cleanup failed:", lines)
        self.assertIn("RuntimeError: cleanup went wrong", out)
        # The cleanup registered before the failing one still runs.
        self.assertEqual(self.logged(), ["scenario ran", "first cleanup"])
        self.assertEqual(lines[-1], summary(0, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_exit_from_a_step_fails_the_scenario(self):
        # sys.exit(0) in a step must not end the run with status 0 and
        # no summary, which would read as a green run.
        path = feature("exit.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "FAIL {}:3 A step that exits the interpreter fails its scenario"
            .format(path), lines
        )
        self.assertIn(
            "  {}:6: failed: And a step that exits with status 0"
            .format(path), lines
        )
        self.assertIn("SystemExit: 0", out)
        self.assertIn(
            "PASS {}:9 A later scenario still runs after an exit"
            .format(path), lines
        )
        # The exit stops its scenario, its cleanup runs, the next runs.
        self.assertEqual(self.logged(), [
            "before the exit", "cleanup after the exit", "later scenario ran",
        ])
        self.assertEqual(lines[-1], summary(1, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_exit_from_a_cleanup_fails_the_scenario(self):
        path = feature("cleanup_exit.feature")
        code, out, err = self.run_bdd(path)
        lines = out.splitlines()
        self.assertIn(
            "FAIL {}:3 A cleanup that exits the interpreter fails a passing "
            "scenario".format(path), lines
        )
        self.assertIn("  cleanup failed:", lines)
        self.assertIn("SystemExit: 0", out)
        self.assertIn(
            "PASS {}:8 A later scenario still runs after a cleanup exits"
            .format(path), lines
        )
        # The cleanup registered before the exiting one still runs.
        self.assertEqual(self.logged(), [
            "scenario ran", "first cleanup", "later scenario ran",
        ])
        self.assertEqual(lines[-1], summary(1, 1, 0, 0))
        self.assertEqual(code, 1, out + err)

    def test_interrupt_stops_the_run_after_cleanups(self):
        path = feature("interrupt.feature")
        code, out, err = self.run_bdd(path)
        self.assertIn("KeyboardInterrupt", err)
        # The interrupted scenario's cleanup runs, and nothing after it.
        self.assertEqual(self.logged(), [
            "before the interrupt", "cleanup after the interrupt",
        ])
        self.assertNotEqual(code, 0, out + err)

    def test_parse_error_exit_2(self):
        broken = feature("parse_error.feature")
        code, out, err = self.run_bdd(broken, feature("passing.feature"))
        self.assertIn("{}:1: F1 ".format(broken), err)
        # Nothing runs when any file fails to parse.
        self.assertNotIn("PASS", out)
        self.assertEqual(self.logged(), [])
        self.assertEqual(code, 2, out + err)

    def test_missing_path_exit_2(self):
        missing = os.path.join(self.scratch, "no-such.feature")
        code, out, err = self.run_bdd(missing)
        self.assertIn(missing, err)
        self.assertEqual(code, 2, out + err)

    def test_directory_is_searched_for_features(self):
        nested = os.path.join(self.scratch, "features", "nested")
        os.makedirs(nested)
        shutil.copy(feature("passing.feature"), nested)
        code, out, err = self.run_bdd(os.path.join(self.scratch, "features"))
        path = os.path.join(nested, "passing.feature")
        self.assertEqual(out.splitlines(), [
            "PASS {}:4 Every step passes".format(path),
            summary(1, 0, 0, 0),
        ])
        self.assertEqual(code, 0, out + err)

    def test_directory_without_features_exit_0(self):
        empty = os.path.join(self.scratch, "features")
        os.makedirs(empty)
        code, out, err = self.run_bdd(empty)
        self.assertEqual(out.splitlines(), [summary(0, 0, 0, 0)])
        self.assertEqual(code, 0, out + err)


if __name__ == "__main__":
    unittest.main()
