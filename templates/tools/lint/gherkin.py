#!/usr/bin/env python3
r"""Gherkin parser shared by the story lint, the renderers and the BDD runner.

Methodology section 11 pairs every user story with a
`<StoryIdentifier>.feature` file whose scenarios are the story's acceptance
criteria. Gherkin is the plain-text Given/When/Then notation that
Cucumber-family tools execute. This module reads one such file into a small
tree and reports the findings that need nothing beyond the file itself. The
story lint adds the findings that compare a feature with its SysML story.

A Gherkin Feature is one story. It is not the `Feature` requirement def of
the SysML library, nor a SysML feature.

Scope and method
----------------
This is a line-oriented state machine, not a port of the Cucumber parser.
It uses the Python standard library only, so it runs inside a git hook and
on a bare CI runner with no install step. It follows the Gherkin reference
(https://cucumber.io/docs/gherkin/reference/) for the subset that
methodology section 11 allows.

Constructs recognised:

* `Feature:`, `Rule:` (grouping only), `Background:`, `Scenario:` or
  `Example:`, `Scenario Outline:` or `Scenario Template:`, and `Examples:`
  or `Scenarios:`.
* Steps opened by `Given `, `When `, `Then `, `And `, `But ` or `* `. A
  step opened by And, But or `*` takes the kind of the step before it in
  the same Background or scenario, and its kind is unknown when it is the
  first step.
* Doc strings, that is, multi-line text attached to a step, between two
  lines of three double quotes or two lines of three backticks. The
  opening line may name a content type after the delimiter, such as
  `json`. Each content line loses up to as much leading whitespace as the
  opening delimiter is indented by. Inside the doc string, the delimiter
  that opened it may be written escaped, a backslash before each of its
  characters (`\"\"\"`, or the same for backticks), and it reads as
  the bare delimiter, as Cucumber reads it.
* Data tables, one row per line, cells between `|` characters. Inside a
  cell, `\|` reads as `|`, `\\` as `\` and `\n` as a line break. Text
  after the last `|` of a row is ignored, as Cucumber does.
* Tags (`@name`, several per line, on one or more lines) above Feature,
  Rule, a scenario or Examples. Comments are whole lines whose first
  non-blank character is `#`, and a word that starts with `#` on a tag
  line begins a comment that runs to the end of that line. A
  `# language:` comment before the Feature names the keyword language.
* Description lines, that is, free text after a Feature, Rule,
  Background, scenario or Examples header and before its first step,
  table row or child. Feature and scenario descriptions are kept, without
  blank lines. The others are read and dropped.

Keywords come from the KEYWORDS table, keyed by language code. Only `en`
is present, so a `# language:` comment naming any other code is finding
F2. Adding a language means adding its keywords to the table.

Findings
--------
Codes follow the lint table of methodology section 11.

* F1, parse error: a line before the first `Feature:` that is not blank,
  a comment or a tag, a second `Feature:`, free text where no description
  can stand, a step, doc string, table row or Examples where none can
  stand (a step takes one doc string or one table), an unclosed doc
  string, a table row whose cell count differs from the first row, a word
  before any comment on a tag line that does not start with `@`, an `@`
  with no name after it, a tag line not followed by a taggable keyword,
  or a tag above Background or a step.
* F2, language: a `# language:` comment naming a language the table does
  not carry. Parsing stops there, because the keywords are unknown.
* F7, Background: a second Background at one level, a Background after
  the first scenario of its level, or a Background step that is not a
  Given step.
* F8, step order: steps that do not run Given, then When, then Then once
  And, But and `*` have taken their kind, a first step opened by And, But
  or `*`, or a scenario with no When step or no Then step.
* F9, Outline examples: a Scenario Outline with no Examples, Examples
  with no header row or no data rows, a `<placeholder>` in a step, doc
  string or table that is not a column of every Examples table, or
  Examples under a plain Scenario.

parse() reports F1 and F2. It also reports F7 for a second Background,
because the tree holds one Background per level and cannot carry the
second. check_structure() reports the other F7 cases, F8 and F9. It
reports nothing for a tree that came with an F1, because a tree built
around a parse error yields findings that vanish once the error is fixed.

After an F1 the parser skips the offending line, or the doc string or
table it opens, and carries on, so one run reports every independent
error. An F1 before the first `Feature:` and a second `Feature:` stop the
parse instead, since nothing after them can be placed in the tree.
"""

import re
from dataclasses import asdict, dataclass, field
from typing import Dict, List, Optional, Tuple

# Keywords by language code. Header keywords are written without their
# colon, step keywords with their trailing space. A step opened by an
# "and" or "but" keyword takes the kind of the step before it.
KEYWORDS = {
    "en": {
        "feature": ("Feature",),
        "rule": ("Rule",),
        "background": ("Background",),
        "scenario": ("Scenario", "Example"),
        "scenarioOutline": ("Scenario Outline", "Scenario Template"),
        "examples": ("Examples", "Scenarios"),
        "given": ("Given ",),
        "when": ("When ",),
        "then": ("Then ",),
        "and": ("And ", "* "),
        "but": ("But ",),
    },
}  # type: Dict[str, Dict[str, Tuple[str, ...]]]

DEFAULT_LANGUAGE = "en"

_HEADER_KINDS = ("feature", "rule", "background", "scenario",
                 "scenarioOutline", "examples")
_STEP_KINDS = ("given", "when", "then", "and", "but")
_TAGGABLE = ("feature", "rule", "scenario", "scenarioOutline", "examples")

# Position of each step kind in the Given, When, Then order.
_STEP_ORDER = {"given": 0, "when": 1, "then": 2}

_DOC_STRING_DELIMITERS = ('"""', "```")

_RE_LANGUAGE = re.compile(r"^\s*#\s*language\s*:\s*(\S+)\s*$")

# A placeholder is `<name>` with no angle bracket inside and no blank at
# either end, so a comparison such as `a <= b and c >= d` is not one.
_RE_PLACEHOLDER = re.compile(r"<([^<>\s](?:[^<>]*[^<>\s])?)>")


@dataclass
class Finding:
    """One finding, printed as `<path>:<line>: <code> <message> (<ref>)`."""

    path: str
    line: int
    code: str
    message: str
    ref: str = "§11"

    def format(self) -> str:
        return "{}:{}: {} {} ({})".format(
            self.path, self.line, self.code, self.message, self.ref
        )

    def as_dict(self) -> dict:
        return asdict(self)


@dataclass
class Tag:
    """A tag, with its leading `@`."""

    name: str
    line: int


@dataclass
class DocString:
    """A doc string attached to a step. `line` is the opening delimiter."""

    content_type: str
    content: str
    line: int


@dataclass
class Step:
    """A step. `keyword` is as written, `kind` is given, when, then or
    unknown."""

    keyword: str
    kind: str
    text: str
    line: int
    doc_string: Optional[DocString] = None
    table: Optional[List[List[str]]] = None


@dataclass
class Examples:
    """An Examples table of a Scenario Outline."""

    name: str
    tags: List[Tag]
    header: List[str]
    rows: List[List[str]]
    line: int


@dataclass
class Scenario:
    """A Scenario, Example, Scenario Outline or Scenario Template."""

    keyword: str
    outline: bool
    name: str
    tags: List[Tag]
    steps: List[Step]
    examples: List[Examples]
    line: int
    description: List[str]


@dataclass
class Background:
    """Steps that run before every scenario of a Feature or Rule."""

    name: str
    steps: List[Step]
    line: int


@dataclass
class Rule:
    """A Rule, which groups scenarios under one business rule."""

    name: str
    tags: List[Tag]
    background: Optional[Background]
    scenarios: List[Scenario]
    line: int


@dataclass
class Feature:
    """The one Feature of a file, which stands for one user story."""

    name: str
    tags: List[Tag]
    description: List[str]
    language: str
    background: Optional[Background]
    scenarios: List[Scenario]
    rules: List[Rule]
    line: int

    def all_scenarios(self) -> List[Scenario]:
        """Every scenario in file order, those inside a Rule included."""
        scenarios = list(self.scenarios)
        for rule in self.rules:
            scenarios.extend(rule.scenarios)
        return scenarios


@dataclass
class ParseResult:
    """The tree, or None when no Feature was read, and the parse findings."""

    feature: Optional[Feature]
    findings: List[Finding]


@dataclass
class _OpenDocString:
    """A doc string whose closing delimiter has not been read yet."""

    delimiter: str
    indent: int
    content_type: str
    line: int
    step: Optional[Step]
    lines: List[str] = field(default_factory=list)


def _keyword_tables(
    language: str,
) -> Tuple[List[Tuple[str, str]], List[Tuple[str, str]]]:
    """Header and step keyword lists for a language."""
    words = KEYWORDS[language]
    headers = [(word + ":", kind) for kind in _HEADER_KINDS
               for word in words[kind]]
    steps = [(word, kind) for kind in _STEP_KINDS for word in words[kind]]
    return headers, steps


def _split_cells(row: str) -> List[str]:
    """Cells of a stripped table row, unescaped and trimmed."""
    cells = []
    cell = []
    chars = iter(row[1:])
    for char in chars:
        if char == "\\":
            following = next(chars, "")
            if following == "|":
                cell.append("|")
            elif following == "\\":
                cell.append("\\")
            elif following == "n":
                cell.append("\n")
            else:
                cell.append("\\" + following)
        elif char == "|":
            cells.append("".join(cell).strip(" \t"))
            cell = []
        else:
            cell.append(char)
    return cells


def _dedent(line: str, indent: int) -> str:
    """Remove up to `indent` leading whitespace characters."""
    count = 0
    while count < indent and count < len(line) and line[count].isspace():
        count += 1
    return line[count:]


class _Parser:
    """The line-oriented state machine behind parse()."""

    def __init__(self, path: str):
        self.path = path
        self.findings = []  # type: List[Finding]
        self.stopped = False
        self.language = DEFAULT_LANGUAGE
        self.headers, self.steps = _keyword_tables(DEFAULT_LANGUAGE)
        self.feature = None  # type: Optional[Feature]
        # The Feature or Rule that receives a Background or a scenario.
        self.container = None
        # Where description lines go, or None where text is an error.
        self.description = None  # type: Optional[List[str]]
        # Where steps go, or None where a step is an error.
        self.step_list = None  # type: Optional[List[Step]]
        # The scenario that receives Examples, or None outside one.
        self.scenario = None  # type: Optional[Scenario]
        # The Examples whose header row is awaited or has been read.
        self.examples = None  # type: Optional[Examples]
        # The last step, while a doc string or table may still follow it.
        self.arg_step = None  # type: Optional[Step]
        # The table that further rows extend, and its width.
        self.rows = None  # type: Optional[List[List[str]]]
        self.width = 0
        self.pending_tags = []  # type: List[Tag]
        self.doc = None  # type: Optional[_OpenDocString]

    def report(self, line: int, code: str, message: str) -> None:
        self.findings.append(Finding(self.path, line, code, message))

    def feed(self, number: int, line: str) -> None:
        stripped = line.strip()
        if self.doc is not None:
            self.doc_line(line, stripped)
            return
        if not stripped:
            return
        if stripped.startswith("#"):
            if self.feature is None:
                self.language_comment(number, line)
            return
        if stripped.startswith("@"):
            self.tag_line(number, stripped)
            return
        header = self.match_header(stripped)
        is_feature = header is not None and header[0] == "feature"
        if self.feature is None and not is_feature:
            self.report(number, "F1", "expected 'Feature:' first, found '{}'"
                        .format(stripped))
            self.stopped = True
            return
        if header is not None:
            kind, keyword, name = header
            tags = self.take_tags(kind)
            self.header_line(number, kind, keyword, name, tags)
            return
        step = self.match_step(stripped)
        if step is not None:
            self.take_tags("step")
            self.step_line(number, *step)
            return
        self.take_tags("other")
        if stripped.startswith(_DOC_STRING_DELIMITERS):
            self.open_doc_string(number, line, stripped)
        elif stripped.startswith("|"):
            self.table_row(number, stripped)
        else:
            self.text_line(number, stripped)

    def finish(self) -> None:
        if self.doc is not None:
            self.report(self.doc.line, "F1",
                        "doc string opened here is never closed")
        self.take_tags("end")

    # Line classification

    def match_header(self, stripped: str):
        for word, kind in self.headers:
            if stripped.startswith(word):
                return kind, word[:-1], stripped[len(word):].strip()
        return None

    def match_step(self, stripped: str):
        for word, kind in self.steps:
            if stripped.startswith(word):
                return word.strip(), kind, stripped[len(word):].strip()
        return None

    # Comments and tags

    def language_comment(self, number: int, line: str) -> None:
        match = _RE_LANGUAGE.match(line)
        if match is None:
            return
        language = match.group(1)
        if language not in KEYWORDS:
            self.report(number, "F2",
                        "language '{}' is not supported, supported: {}"
                        .format(language, ", ".join(sorted(KEYWORDS))))
            self.stopped = True
            return
        self.language = language
        self.headers, self.steps = _keyword_tables(language)

    def tag_line(self, number: int, stripped: str) -> None:
        for token in stripped.split():
            if token.startswith("#"):
                # A comment ends the tags of its line.
                break
            if token.startswith("@") and len(token) > 1:
                self.pending_tags.append(Tag(token, number))
            elif token == "@":
                self.report(number, "F1", "a tag needs a name after @")
            else:
                self.report(number, "F1",
                            "'{}' on a tag line is not a tag, tags start "
                            "with '@'".format(token))

    def take_tags(self, kind: str) -> List[Tag]:
        """Hand pending tags to a taggable keyword, or report them."""
        tags, self.pending_tags = self.pending_tags, []
        if not tags or kind in _TAGGABLE:
            return tags
        if kind == "background":
            message = "tags cannot be placed above Background"
        elif kind == "step":
            message = "tags cannot be placed above a step"
        else:
            message = ("tags must be followed by Feature, Rule, Scenario, "
                       "Scenario Outline or Examples")
        self.report(tags[0].line, "F1", message)
        return []

    # Keywords

    def enter(self, description: Optional[List[str]],
              step_list: Optional[List[Step]],
              scenario: Optional[Scenario],
              examples: Optional[Examples] = None) -> None:
        self.description = description
        self.step_list = step_list
        self.scenario = scenario
        self.examples = examples
        self.arg_step = None
        self.rows = None

    def header_line(self, number: int, kind: str, keyword: str, name: str,
                    tags: List[Tag]) -> None:
        if kind == "feature":
            if self.feature is not None:
                self.report(number, "F1",
                            "a second Feature, a file holds one Feature")
                self.stopped = True
                return
            self.feature = Feature(name, tags, [], self.language, None, [],
                                   [], number)
            self.container = self.feature
            self.enter(self.feature.description, None, None)
        elif kind == "rule":
            rule = Rule(name, tags, None, [], number)
            self.feature.rules.append(rule)
            self.container = rule
            self.enter([], None, None)
        elif kind == "background":
            background = Background(name, [], number)
            if self.container.background is None:
                self.container.background = background
            else:
                self.report(number, "F7",
                            "a second Background at this level, a Feature "
                            "or Rule holds one")
            self.enter([], background.steps, None)
        elif kind == "examples":
            examples = Examples(name, tags, [], [], number)
            if self.scenario is None:
                self.report(number, "F1",
                            "Examples must follow a Scenario Outline")
            else:
                self.scenario.examples.append(examples)
            self.enter([], None, self.scenario, examples)
        else:
            scenario = Scenario(keyword, kind == "scenarioOutline", name,
                                tags, [], [], number, [])
            self.container.scenarios.append(scenario)
            self.enter(scenario.description, scenario.steps, scenario)

    # Steps, doc strings, tables and text

    def step_line(self, number: int, keyword: str, kind: str,
                  text: str) -> None:
        self.description = None
        self.rows = None
        if self.step_list is None:
            if self.examples is not None:
                message = "steps must come before Examples"
            else:
                message = "step outside a Scenario or Background"
            self.report(number, "F1", message)
            # Keep the step out of the tree but let its doc string or
            # table attach to it, so they are not reported as well.
            self.arg_step = Step(keyword, "unknown", text, number)
            return
        if kind not in _STEP_ORDER:
            kind = self.step_list[-1].kind if self.step_list else "unknown"
        step = Step(keyword, kind, text, number)
        self.step_list.append(step)
        self.arg_step = step

    def open_doc_string(self, number: int, line: str, stripped: str) -> None:
        self.description = None
        self.rows = None
        delimiter = stripped[:3]
        step = self.arg_step
        if step is not None and (step.doc_string is not None
                                 or step.table is not None):
            step = None
        if step is None:
            self.report(number, "F1", "doc string does not follow a step")
        self.doc = _OpenDocString(
            delimiter=delimiter,
            indent=len(line) - len(line.lstrip()),
            content_type=stripped[3:].strip(),
            line=number,
            step=step,
        )

    def doc_line(self, line: str, stripped: str) -> None:
        doc = self.doc
        if stripped == doc.delimiter:
            if doc.step is not None:
                doc.step.doc_string = DocString(
                    doc.content_type, "\n".join(doc.lines), doc.line
                )
            self.doc = None
            return
        # The delimiter that opened the doc string may appear inside it
        # escaped, each character after a backslash, and reads bare.
        escaped = "".join("\\" + char for char in doc.delimiter)
        doc.lines.append(
            _dedent(line, doc.indent).replace(escaped, doc.delimiter))

    def table_row(self, number: int, stripped: str) -> None:
        cells = _split_cells(stripped)
        self.description = None
        if self.rows is not None:
            if len(cells) != self.width:
                self.report(number, "F1",
                            "table row has {} cells, the first row has {}"
                            .format(len(cells), self.width))
                return
            self.rows.append(cells)
            return
        self.width = len(cells)
        if self.examples is not None and not self.examples.header:
            self.examples.header = cells
            self.rows = self.examples.rows
            return
        step = self.arg_step
        if step is not None and step.doc_string is None and step.table is None:
            step.table = [cells]
            self.rows = step.table
            return
        self.report(number, "F1",
                    "table row does not follow a step or an Examples line")
        # Absorb the rest of this table so each row is not reported.
        self.rows = [cells]

    def text_line(self, number: int, stripped: str) -> None:
        self.arg_step = None
        self.rows = None
        if self.description is not None:
            self.description.append(stripped)
            return
        self.report(number, "F1",
                    "expected a keyword, step, table row, doc string, tag "
                    "or comment, found '{}'".format(stripped))


def parse(text: str, path: str = "<string>") -> ParseResult:
    """Parse Gherkin text. `path` labels the findings. One leading byte
    order mark (U+FEFF) is dropped."""
    if text.startswith("\ufeff"):
        text = text[1:]
    parser = _Parser(path)
    for number, line in enumerate(text.split("\n"), 1):
        if line.endswith("\r"):
            line = line[:-1]
        parser.feed(number, line)
        if parser.stopped:
            break
    else:
        parser.finish()
    return ParseResult(parser.feature, parser.findings)


def parse_file(path: str) -> ParseResult:
    """Parse a `.feature` file. parse() drops a byte order mark."""
    with open(path, encoding="utf-8") as handle:
        return parse(handle.read(), path)


def _check_background(level, path: str, findings: List[Finding]) -> None:
    background = level.background
    if background is None:
        return
    if level.scenarios and background.line > level.scenarios[0].line:
        findings.append(Finding(
            path, background.line, "F7",
            "Background comes after the first scenario of its level, it "
            "must come before"))
    for step in background.steps:
        if step.kind != "given":
            findings.append(Finding(
                path, step.line, "F7",
                "Background step '{} {}' is not a Given step"
                .format(step.keyword, step.text)))


def _check_steps(scenario: Scenario, path: str,
                 findings: List[Finding]) -> None:
    steps = scenario.steps
    if steps and steps[0].kind == "unknown":
        findings.append(Finding(
            path, steps[0].line, "F8",
            "the first step opens with '{}', which has no earlier step to "
            "take its kind from".format(steps[0].keyword)))
    names = ("Given", "When", "Then")
    phase = 0
    for step in steps:
        order = _STEP_ORDER.get(step.kind)
        if order is None:
            continue
        if order < phase:
            findings.append(Finding(
                path, step.line, "F8",
                "'{} {}' is a {} step after a {} step, steps run Given, "
                "then When, then Then".format(
                    step.keyword, step.text, names[order],
                    names[phase])))
            break
        phase = order
    kinds = [step.kind for step in steps]
    for kind, name in (("when", "When"), ("then", "Then")):
        if kind not in kinds:
            findings.append(Finding(
                path, scenario.line, "F8",
                "scenario '{}' has no {} step".format(
                    scenario.name, name)))


def _step_placeholders(step: Step) -> List[Tuple[str, str]]:
    """Placeholder names in a step, each once, with where they appear."""
    sources = [("step text", step.text)]
    if step.doc_string is not None:
        sources.append(("doc string", step.doc_string.content))
    for row in step.table or []:
        sources.extend(("table", cell) for cell in row)
    found = []  # type: List[Tuple[str, str]]
    seen = set()
    for where, text in sources:
        for name in _RE_PLACEHOLDER.findall(text):
            if name not in seen:
                seen.add(name)
                found.append((name, where))
    return found


def _check_examples(scenario: Scenario, path: str,
                    findings: List[Finding]) -> None:
    if not scenario.outline:
        for examples in scenario.examples:
            findings.append(Finding(
                path, examples.line, "F9",
                "Examples under a plain Scenario, use Scenario Outline"))
        return
    if not scenario.examples:
        findings.append(Finding(
            path, scenario.line, "F9",
            "Scenario Outline '{}' has no Examples".format(
                scenario.name)))
        return
    for examples in scenario.examples:
        if not examples.header:
            findings.append(Finding(path, examples.line, "F9",
                                    "Examples has no header row"))
        elif not examples.rows:
            findings.append(Finding(path, examples.line, "F9",
                                    "Examples has a header row but no data "
                                    "rows"))
    headed = [examples for examples in scenario.examples if examples.header]
    for step in scenario.steps:
        for name, where in _step_placeholders(step):
            for examples in headed:
                if name not in examples.header:
                    findings.append(Finding(
                        path, step.line, "F9",
                        "placeholder <{}> in the {} is not a column of the "
                        "Examples at line {}".format(name, where,
                                                     examples.line)))


def check_structure(result: ParseResult, path: str) -> List[Finding]:
    """F7, F8 and F9 for a parsed tree."""
    feature = result.feature
    if feature is None:
        return []
    if any(finding.code == "F1" for finding in result.findings):
        return []
    findings = []  # type: List[Finding]
    for level in [feature] + feature.rules:
        _check_background(level, path, findings)
    for scenario in feature.all_scenarios():
        _check_steps(scenario, path, findings)
        _check_examples(scenario, path, findings)
    return findings


def _substitute(text: str, values: Dict[str, str]) -> str:
    return _RE_PLACEHOLDER.sub(
        lambda match: values.get(match.group(1), match.group(0)), text
    )


def _substitute_step(step: Step, values: Dict[str, str]) -> Step:
    doc_string = None
    if step.doc_string is not None:
        doc_string = DocString(step.doc_string.content_type,
                               _substitute(step.doc_string.content, values),
                               step.doc_string.line)
    table = None
    if step.table is not None:
        table = [[_substitute(cell, values) for cell in row]
                 for row in step.table]
    return Step(step.keyword, step.kind, _substitute(step.text, values),
                step.line, doc_string=doc_string, table=table)


def expand_outline(scenario: Scenario) -> List[Tuple[str, List[Step]]]:
    """One (name, steps) pair per Examples row, placeholders filled in.

    A plain scenario comes back once, unchanged. Placeholders are filled
    in the scenario name, the step text, doc strings and table cells. A
    placeholder with no column in the row is left as written.
    """
    if not scenario.outline:
        return [(scenario.name, scenario.steps)]
    expanded = []
    for examples in scenario.examples:
        for row in examples.rows:
            values = dict(zip(examples.header, row))
            expanded.append((
                _substitute(scenario.name, values),
                [_substitute_step(step, values) for step in scenario.steps],
            ))
    return expanded
