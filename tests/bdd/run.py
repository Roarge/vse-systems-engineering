#!/usr/bin/env python3
"""Run the plugin's Gherkin scenarios against Python step definitions.

The plugin describes its own behaviour as Gherkin scenarios in
tests/features/. Gherkin is the plain-text Given/When/Then notation that
Cucumber-family tools execute. This runner executes the scenarios with
the Python standard library only, so it needs no install step on a bare
CI runner. It reads each file with the parser the story lint uses
(templates/tools/lint/gherkin.py) and matches each step against the
definitions in a steps directory, as tests/bdd/steps/__init__.py
describes.

Usage:

    python3 tests/bdd/run.py [--steps DIR] [--include-wip] PATH...

Each PATH is a `.feature` file or a directory, which is searched for
`.feature` files, subdirectories included. The steps directory defaults
to tests/bdd/steps.

Every scenario runs in a fresh context. A Scenario Outline runs once per
Examples row, with the row's values filled in. The Feature's Background
steps run first, then those of the scenario's Rule, then the scenario's
own. A scenario tagged `@wip` (work in progress), directly or through
its Rule or Feature, is skipped unless `--include-wip` is given.

A step stops its scenario when it raises an exception or calls
sys.exit() (failed), when no definition matches it (undefined), or when
more than one does (ambiguous, which counts as failed). The cleanups the
scenario registered run after its last step either way, and a cleanup
that raises or calls sys.exit() fails a scenario that had passed. An
interrupt (Ctrl-C) stops the whole run once the interrupted scenario's
cleanups have run.

Output is one line per scenario, `PASS`, `FAIL`, `UNDEFINED` or `SKIP`
followed by `<path>:<line> <name>`, with indented detail lines under a
FAIL or UNDEFINED, then one summary line:

    bdd: N passed, N failed, N undefined, N skipped

Every row of a Scenario Outline reports the line of the outline itself,
because the parser does not record the line of an Examples row.

Exit status: 0 when no scenario failed or was undefined, 1 otherwise,
and 2 for bad usage or when a file does not parse. Every file is parsed
before any scenario runs, so a parse error runs nothing.
"""

import argparse
import os
import sys
import traceback
from typing import Callable, Dict, Iterator, List, Optional, Tuple

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

# The parser ships as a loose script beside the story lint, so its
# directory goes on the path. No bytecode is written there, because the
# directory is mirrored byte for byte into the demo. The runner's own
# directory goes on the path as well, so that the steps package imports
# even when Python leaves the script directory off the path (`-I`).
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(REPO, "templates", "tools", "lint"))
sys.path.insert(0, HERE)

import gherkin  # noqa: E402
from steps import (  # noqa: E402
    REGISTRY,
    STEP_ERRORS,
    Context,
    load_step_modules,
)

WIP_TAG = "@wip"


def feature_files(paths: List[str]) -> List[str]:
    """The `.feature` files named by `paths`, directories searched in
    sorted order."""
    found = []  # type: List[str]
    for path in paths:
        if not os.path.isdir(path):
            found.append(path)
            continue
        for root, dirs, names in os.walk(path):
            dirs.sort()
            found.extend(os.path.join(root, name) for name in sorted(names)
                         if name.endswith(".feature"))
    return found


def _background(level) -> List[gherkin.Step]:
    """The Background steps of a Feature or Rule, or none."""
    if level.background is None:
        return []
    return level.background.steps


def scenario_runs(
    feature: gherkin.Feature,
) -> Iterator[Tuple[str, int, List[gherkin.Step], bool]]:
    """(name, line, steps, wip) for each run of each scenario in file
    order, with outline rows expanded and Background steps prepended."""
    levels = [(_background(feature), feature.tags, feature.scenarios)]
    for rule in feature.rules:
        levels.append((_background(feature) + _background(rule),
                       feature.tags + rule.tags, rule.scenarios))
    for background, tags, scenarios in levels:
        for scenario in scenarios:
            wip = any(tag.name == WIP_TAG for tag in tags + scenario.tags)
            for name, steps in gherkin.expand_outline(scenario):
                yield name, scenario.line, background + steps, wip


def definitions(text: str) -> List[Tuple[str, Callable, tuple]]:
    """(pattern, function, groups) for every registered step whose
    pattern matches the whole of `text`."""
    found = []  # type: List[Tuple[str, Callable, tuple]]
    for pattern, function in REGISTRY:
        match = pattern.fullmatch(text)
        if match is not None:
            found.append((pattern.pattern, function, match.groups()))
    return found


def format_error(error: BaseException) -> List[str]:
    """The traceback of `error` without the runner's own frame, as
    indented detail lines."""
    text = "".join(traceback.format_exception(
        type(error), error, error.__traceback__.tb_next))
    return ["    " + line for line in text.splitlines()]


def run_scenario(path: str,
                 steps: List[gherkin.Step]) -> Tuple[str, List[str]]:
    """Run one scenario's steps in a fresh context. Return its status
    and its detail lines."""
    ctx = Context()
    status = "PASS"
    details = []  # type: List[str]
    try:
        for item in steps:
            where = "  {}:{}: ".format(path, item.line)
            label = "{} {}".format(item.keyword, item.text)
            found = definitions(item.text)
            if not found:
                status = "UNDEFINED"
                details.append(where + "undefined: " + label)
                break
            if len(found) > 1:
                status = "FAIL"
                details.append(where + "ambiguous: " + label)
                details.extend("    matches {!r} ({}.{})".format(
                    pattern, function.__module__, function.__name__)
                    for pattern, function, _ in found)
                break
            _, function, groups = found[0]
            ctx.doc_string = (item.doc_string.content
                              if item.doc_string is not None else None)
            ctx.table = item.table
            try:
                function(ctx, *groups)
            except STEP_ERRORS as error:
                status = "FAIL"
                details.append(where + "failed: " + label)
                details.extend(format_error(error))
                break
    finally:
        # An interrupt still propagates, but only after the cleanups.
        errors = ctx.run_cleanups()
    if errors:
        if status == "PASS":
            status = "FAIL"
        details.append("  cleanup failed:")
        for error in errors:
            details.extend(format_error(error))
    return status, details


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        prog="run.py",
        description="Run Gherkin scenarios against Python step "
                    "definitions.",
    )
    parser.add_argument("--steps", metavar="DIR",
                        default=os.path.join(HERE, "steps"),
                        help="directory of step modules (default: "
                             "tests/bdd/steps)")
    parser.add_argument("--include-wip", action="store_true",
                        help="also run scenarios tagged @wip")
    parser.add_argument("paths", nargs="+", metavar="PATH",
                        help="a .feature file, or a directory to search")
    args = parser.parse_args(argv)
    for path in args.paths:
        if not os.path.exists(path):
            parser.error("no such file or directory: {}".format(path))
    if not os.path.isdir(args.steps):
        parser.error("no such steps directory: {}".format(args.steps))

    features = []  # type: List[Tuple[str, gherkin.Feature]]
    findings = []  # type: List[gherkin.Finding]
    for path in feature_files(args.paths):
        result = gherkin.parse_file(path)
        findings.extend(result.findings)
        if result.feature is not None:
            features.append((path, result.feature))
    if findings:
        for finding in findings:
            print(finding.format(), file=sys.stderr)
        return 2

    load_step_modules(args.steps)
    counts = {"PASS": 0, "FAIL": 0, "UNDEFINED": 0,
              "SKIP": 0}  # type: Dict[str, int]
    for path, feature in features:
        for name, line, steps, wip in scenario_runs(feature):
            if wip and not args.include_wip:
                status, details = "SKIP", []
            else:
                status, details = run_scenario(path, steps)
            counts[status] += 1
            print("{} {}:{} {}".format(status, path, line, name))
            for detail in details:
                print(detail)
    print("bdd: {PASS} passed, {FAIL} failed, {UNDEFINED} undefined, "
          "{SKIP} skipped".format(**counts))
    return 0 if counts["FAIL"] == counts["UNDEFINED"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
