r"""Step definitions for the plugin's Gherkin scenarios.

tests/bdd/run.py runs the scenarios in tests/features/. Each step of a
scenario is matched against the patterns registered here with the
`step` decorator, and the matching function runs.

A step module in this directory looks like this:

    from steps import step

    @step(r"the lint reports (\d+) findings?")
    def lint_reports(ctx, count):
        assert len(ctx.findings) == int(count), ctx.findings

A pattern is a regular expression that must match the whole step text,
that is, the text after the Given, When, Then, And, But or `*` keyword.
The keyword plays no part, so one definition serves a step whichever
keyword opens it. The groups of the match are passed to the function
after the context, as positional strings.

The context (`ctx`) is a fresh `Context` for every scenario. Steps share
state by setting attributes on it. Before each step the runner sets
`ctx.doc_string` to the text of the step's doc string and `ctx.table` to
the rows of its data table (the header row first), or to None when the
step has none. The table is the step's own copy, so a step may change it
without changing what a later scenario sees. `ctx.cleanup(fn)` registers
a function to run when the scenario ends, whether it passed or not.

The runner imports every `*.py` file in the steps directory except this
one, each under its file name, with the directory on the module search
path. A step module therefore imports a helper module beside it by its
bare name, and must not share its name with a standard library module.
A module that fails to import, through a syntax error, a failed import,
or an exception or sys.exit() at module level, stops the run before any
scenario. The runner then prints `<module path>: <error>` and exits 2.
"""

import importlib
import os
import re
import sys
from typing import Callable, List, Tuple

# Every registered step as (compiled pattern, function), in the order
# the step modules registered them.
REGISTRY = []  # type: List[Tuple[re.Pattern, Callable]]

# What a step or a cleanup may raise and still only fail its scenario.
# SystemExit is not an Exception, but sys.exit() in a step (or an
# in-process command-line main() given --help or a bad argument) must
# fail that scenario, not end the run with the step's exit status.
# KeyboardInterrupt (Ctrl-C) stays out, so an interrupt stops the run.
STEP_ERRORS = (Exception, SystemExit)


def step(pattern: str) -> Callable:
    """Register the decorated function for steps whose whole text matches
    `pattern`."""
    compiled = re.compile(pattern)

    def register(function: Callable) -> Callable:
        REGISTRY.append((compiled, function))
        return function

    return register


class Context:
    """The state the steps of one scenario share, as plain attributes."""

    def __init__(self) -> None:
        self.doc_string = None
        self.table = None
        self._cleanups = []  # type: List[Callable]

    def cleanup(self, function: Callable) -> Callable:
        """Run `function` when the scenario ends, last registered first."""
        self._cleanups.append(function)
        return function

    def run_cleanups(self) -> List[BaseException]:
        """Run every registered cleanup, last registered first, and return
        the exceptions they raised, sys.exit() included. A failing
        cleanup does not stop the others."""
        errors = []  # type: List[BaseException]
        while self._cleanups:
            function = self._cleanups.pop()
            try:
                function()
            except STEP_ERRORS as error:
                errors.append(error)
        return errors


class StepModuleError(Exception):
    """A step module failed to import. Reads `<path>: <error>`."""

    def __init__(self, path: str, error: BaseException) -> None:
        super().__init__("{}: {}: {}".format(
            path, type(error).__name__, error))


def load_step_modules(directory: str) -> None:
    """Import every `*.py` file in `directory` except `__init__.py`.

    Raise StepModuleError for the first module whose import raises or
    calls sys.exit(), a SyntaxError or an ImportError included.
    """
    search = os.path.abspath(directory)
    if search not in sys.path:
        sys.path.insert(0, search)
    for name in sorted(os.listdir(search)):
        if name.endswith(".py") and name != "__init__.py":
            try:
                importlib.import_module(name[:-3])
            except STEP_ERRORS as error:
                raise StepModuleError(os.path.join(directory, name),
                                      error) from error
