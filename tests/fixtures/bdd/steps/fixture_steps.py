"""Step definitions for the BDD runner's own tests.

tests/python/test_bdd_runner.py runs tests/bdd/run.py with `--steps`
naming this directory. A step that records what happened appends one
line to the file named by the BDD_FIXTURE_LOG environment variable, so a
test can check which steps and cleanups ran, and in which order.
"""

import os
import sys

from steps import step


def log(text):
    with open(os.environ["BDD_FIXTURE_LOG"], "a", encoding="utf-8") as handle:
        handle.write(text + "\n")


@step(r"a passing step")
def passing_step(ctx):
    pass


@step(r'I log "(.*)"')
def log_text(ctx, text):
    log(text)


@step(r"the number (\d+) is even")
def number_is_even(ctx, number):
    assert int(number) % 2 == 0, "{} is odd".format(number)


# Both patterns match "the ambiguous step", so the runner must refuse it.
@step(r"the ambiguous step")
def ambiguous_exact(ctx):
    pass


@step(r"the ambiguous .*")
def ambiguous_loose(ctx):
    pass


@step(r'a cleanup that logs "(.*)"')
def cleanup_that_logs(ctx, text):
    ctx.cleanup(lambda: log(text))


@step(r"a cleanup that raises")
def cleanup_that_raises(ctx):
    def fail():
        raise RuntimeError("cleanup went wrong")

    ctx.cleanup(fail)


# sys.exit raises SystemExit, which is not an Exception. An in-process
# command-line main() does the same on --help or a bad argument.
@step(r"a step that exits with status (\d+)")
def step_that_exits(ctx, status):
    sys.exit(int(status))


@step(r"a cleanup that exits with status (\d+)")
def cleanup_that_exits(ctx, status):
    ctx.cleanup(lambda: sys.exit(int(status)))


# Ctrl-C raises KeyboardInterrupt, which must stop the run, not fail one
# scenario and carry on.
@step(r"a step that is interrupted")
def step_that_is_interrupted(ctx):
    raise KeyboardInterrupt


@step(r"the context is fresh")
def context_is_fresh(ctx):
    assert not hasattr(ctx, "touched"), "state leaked from another scenario"


@step(r"I touch the context")
def touch_context(ctx):
    ctx.touched = True


@step(r'the doc string reads "(.*)"')
def doc_string_reads(ctx, expected):
    assert ctx.doc_string == expected, repr(ctx.doc_string)


@step(r"the table has (\d+) rows and its first cell is (\w+)")
def table_shape(ctx, count, first):
    assert ctx.table is not None, "no table reached the step"
    assert len(ctx.table) == int(count), repr(ctx.table)
    assert ctx.table[0][0] == first, repr(ctx.table)


# A Background step runs once per scenario from the same parsed step, so
# a change it makes to its table must not reach the next scenario. The
# header row is both removed and changed, so a copy of the outer list
# alone does not pass.
@step(r"I take the header row from a table of (\d+) rows headed (\w+)")
def take_header_row(ctx, count, first):
    assert len(ctx.table) == int(count), repr(ctx.table)
    header = ctx.table.pop(0)
    assert header[0] == first, repr(header)
    header[0] = "taken"


@step(r"the step has no doc string or table")
def no_argument(ctx):
    assert ctx.doc_string is None, repr(ctx.doc_string)
    assert ctx.table is None, repr(ctx.table)
