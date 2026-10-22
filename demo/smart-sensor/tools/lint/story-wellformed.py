#!/usr/bin/env python3
"""Story lint: keep each user story and its Gherkin feature file in step.

Methodology section 11 pairs every user story with a
`<StoryIdentifier>.feature` file beside the `.sysml` file that declares
it. Each scenario in the feature file states one acceptance criterion,
and each criterion is mirrored in the model by a named requirement
nested inside the story's `requirement :>> acceptance`. This lint checks
both sides and the link between them, and it checks the story
well-formedness rules of section 1.9.

Usage, from the engineering root (the directory that holds
`.iso-config.yaml`):

    python3 tools/lint/story-wellformed.py [--only wellformed|gherkin|syntax]
        [--format text|json] PATH...

Each PATH is a `.sysml` file, a `.feature` file or a directory, which is
searched with its subdirectories. Files whose names start with `_` are
templates and are skipped. A search reads regular files, directly or
through a link, and dangling links, which it reports as unreadable, so
a named pipe, a socket or a device is never opened. A file that two
searched directories reach, one through a link, draws each finding
once.

Rule sets
---------
* `--only wellformed`: section 1.9 rules 2, 3, 6 and 9 and the
  `storymeta` fields, codes W2, W3, W6, W9 and W10, for the stories in
  the `.sysml` files named or found. This is the
  `precommit_story_wellformed` gate. W3 checks that the role is typed,
  without resolving the type to a part definition, because the type may
  come from an imported library.
* `--only gherkin`: findings S1 to S9 and F1 to F10 of section 11.9.1,
  for every directory that holds a named file or that a named directory
  search finds. This is the `precommit_gherkin` gate. Section 11.2.1
  pairs stories with feature files in stories directories, so the story
  findings are reported only for a directory named `stories` or one
  inside it. A story declared elsewhere is not checked, and a feature
  file beside it draws F10.
* `--only syntax`: F1, F2, F7, F8 and F9 for the `.feature` files named
  or found, with no story context.
* No `--only`: wellformed and gherkin.

A finding carries one disposition. A `.sysml` file that cannot be read,
or is not UTF-8, is S9 under the gherkin rule set alone, and the
wellformed rule set skips it.

A story is what the plugin's in-session Gherkin-first hook reads as one:
a requirement usage declared as `requirement <ID> : UserStory` or
`requirement <ID> : VSE_Library::UserStory`. Any other declaration that
types or specialises UserStory in a stories directory is finding S9, so
that a story the hook cannot read never passes unchecked.

Finding S8 reads every verification and validation case, and every
`satisfy`, in the model root (`model/` or `engineering/model/` under the
current directory), as well as in the files linted, so naming only a
stories directory is enough.

The `storymeta` block of `.iso-config.yaml`, when present, sets
`required_fields` (required once a story leaves backlog) and
`valid_statuses`. Without it, status alone is required and the four
statuses of section 1.5 are valid. Status itself is required whatever
the story's state, because the other checks depend on it. A story with
no status draws that one W10 finding, not one per required field.

A status that cannot be read, or that the section 11.4 ordering table
does not rank (one a project adds through `valid_statuses`), holds the
story to the strictest row of that table for S8, and W3 counts it as
past backlog, so a story is never left unchecked.

The story's narrative attributes, role and `@StoryMeta` values are read
from the lint's own statement scanner, so a story written on one line
reads the same as the usual layout. From the model reader the lint
takes its comment stripping, its string unescaping, and the cases and
`satisfy` relationships that S8 needs.

Output
------
One finding per line, `<path>:<line>: <code> <message> (<reference>)`, or
a JSON array of objects with the keys path, line, code, message and ref,
sorted by path, line and code. Exit status 0 means clean, 1 means
findings, and 2 means a usage or environment error, such as a missing
path, a missing `tools/render/` beside `tools/lint/`, a file system
error, a failure to write the findings (a closed pipe or a full disk),
or an unexpected error in the lint itself. An error is one line on
standard error, never a traceback.

The lint uses the Python standard library only. It reads feature files
with gherkin.py beside it and the model with ../render/sysml_model.py.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterator, List, Optional, Tuple

# The lint is installed into a project's tools/ directory, which is not
# a place for bytecode caches.
sys.dont_write_bytecode = True

HERE = os.path.dirname(os.path.abspath(__file__))
RENDER = os.path.normpath(os.path.join(HERE, os.pardir, "render"))
sys.path.insert(0, RENDER)
sys.path.insert(0, HERE)

IMPORT_ERROR = None  # type: Optional[str]
try:
    import gherkin
    from gherkin import Finding
except ImportError as error:
    IMPORT_ERROR = "cannot import gherkin.py from {} ({})".format(HERE, error)
try:
    import sysml_model
except ImportError as error:
    IMPORT_ERROR = ("cannot import sysml_model.py from {} ({}). The story "
                    "lint needs tools/render/ installed beside tools/lint/"
                    .format(RENDER, error))

MODES = ("wellformed", "gherkin", "syntax")
# The rows of the section 11.4 ordering table. A status that cannot be
# read, or that the table does not rank, is held to the strictest row.
STATUS_RANK = {"backlog": 0, "ready": 1, "inProgress": 2, "done": 2}
STRICTEST = max(STATUS_RANK.values())
DEFAULT_STATUSES = ["backlog", "ready", "inProgress", "done"]
ENUMERATIONS = {"priority": "Priority", "status": "StoryStatus",
                "invest": "InvestFlags"}
VISIBILITY = ("public", "private", "protected")
CONFIG = ".iso-config.yaml"

_RE_IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_RE_CRITERION = re.compile(r"[a-z][A-Za-z0-9]*")
_RE_TOKEN = re.compile(
    r'(?P<space>\s+)'
    r'|(?P<string>"(?:[^"\\]|\\.)*"?)'
    r'|(?P<name>[A-Za-z_][A-Za-z0-9_]*)'
    r'|(?P<number>[0-9][0-9.]*)'
    r'|(?P<symbol>::>|::|:>>|:>|.)',
    re.DOTALL,
)

# The section reference for the findings gherkin.py reports, and the fix
# where its message does not already state it.
PARSER_FINDINGS = {
    "F1": ("§11.2.4", ""),
    "F2": ("§11.2.2", "Write the feature in English, with "
                      "'# language: en' or no language header"),
    "F7": ("§11.2.4", "A Background holds Given steps only, once per "
                      "Feature or Rule, before the first scenario"),
    "F8": ("§11.2.4", ""),
    "F9": ("§11.2.4", "Give each Scenario Outline an Examples table with "
                      "a header row naming every placeholder and at least "
                      "one data row"),
}


class LintError(Exception):
    """A usage or environment error, reported with exit status 2."""


# ---------------------------------------------------------------------------
# Reading SysML: statements, stories and their shape
# ---------------------------------------------------------------------------


@dataclass
class Statement:
    """Tokens up to `;`, `{` or `}`, with the block a `{` opens.

    A `requirement` keyword always starts a new statement, as in the
    hook library's scanner, so `#derive requirement X` reads as two.
    """

    words: List[str]
    kinds: List[str]
    line: int
    end: str
    body: List["Statement"] = field(default_factory=list)

    def head(self) -> Tuple[List[str], List[str]]:
        """Words and kinds after any leading visibility keyword."""
        index = 0
        while index < len(self.words) and self.words[index] in VISIBILITY:
            index += 1
        return self.words[index:], self.kinds[index:]

    def text(self) -> str:
        return " ".join(self.words)


@dataclass
class StoryBlock:
    """A story declared in the canonical form, with what its body
    declares."""

    identifier: str
    line: int
    shape: "StoryShape"


@dataclass
class StoryScan:
    """Stories in declaration order, and the (line, text) of every
    declaration that types or specialises UserStory in another form."""

    stories: List[StoryBlock] = field(default_factory=list)
    unreadable: List[Tuple[int, str]] = field(default_factory=list)


def _statements(text: str) -> List[Statement]:
    """Statements of comment-free SysML text, blocks nested."""
    root = []  # type: List[Statement]
    stack = [root]
    words = []  # type: List[str]
    kinds = []  # type: List[str]
    start = 0
    line = 1
    for match in _RE_TOKEN.finditer(text):
        kind = match.lastgroup
        value = match.group()
        token_line = line
        line += value.count("\n")
        if kind == "space":
            continue
        if kind == "symbol" and value in ("{", "}", ";"):
            if value == "{":
                statement = Statement(words, kinds,
                                      start if words else token_line, "{")
                stack[-1].append(statement)
                stack.append(statement.body)
            else:
                if words:
                    stack[-1].append(Statement(words, kinds, start, value))
                if value == "}" and len(stack) > 1:
                    stack.pop()
            words, kinds = [], []
            continue
        if kind == "name" and value == "requirement" and words:
            stack[-1].append(Statement(words, kinds, start, ""))
            words, kinds = [], []
        if not words:
            start = token_line
        words.append(value)
        kinds.append(kind)
    if words:
        stack[-1].append(Statement(words, kinds, start, ""))
    return root


def _walk(statements: List[Statement]) -> Iterator[Statement]:
    for statement in statements:
        yield statement
        yield from _walk(statement.body)


def _story_identifier(statement: Statement) -> Optional[str]:
    """The ID of `requirement <ID> : [VSE_Library::]UserStory`, ended by
    `{` or `;`, or None."""
    words, kinds = statement.words, statement.kinds
    if statement.end not in ("{", ";") or len(words) < 4:
        return None
    if words[0] != "requirement" or kinds[1] != "name" or words[2] != ":":
        return None
    if words[3] == "UserStory":
        rest = 4
    elif words[3:6] == ["VSE_Library", "::", "UserStory"]:
        rest = 6
    else:
        return None
    if rest < len(words) and words[rest] == "::":
        return None
    return words[1]


def _declared_name(words: List[str], kinds: List[str]) -> int:
    """Index of the name a requirement statement declares, or -1."""
    index = 1
    if index < len(words) and words[index] == "def":
        index += 1
    if index < len(words) and words[index] == "<":
        while index < len(words) and words[index] != ">":
            index += 1
        index += 1
    if index < len(words) and kinds[index] == "name":
        return index
    return -1


def _misdeclared(statement: Statement) -> bool:
    """True for a requirement that types or specialises UserStory other
    than in the canonical form."""
    words, kinds = statement.words, statement.kinds
    if not words or words[0] != "requirement":
        return False
    if _story_identifier(statement) is not None:
        return False
    name = _declared_name(words, kinds)
    for index in range(1, len(words)):
        if index == name or kinds[index] != "name":
            continue
        if words[index] != "UserStory":
            continue
        if index + 1 < len(words) and words[index + 1] == "::":
            continue
        return True
    return False


def read_stories(text: str) -> StoryScan:
    """Stories and unreadable story declarations in SysML text."""
    clean, docs = sysml_model._strip_comments(text)
    scan = StoryScan()
    for statement in _walk(_statements(clean)):
        identifier = _story_identifier(statement)
        if identifier is not None:
            scan.stories.append(StoryBlock(
                identifier, statement.line, story_shape(statement.body, docs)))
        elif _misdeclared(statement):
            scan.unreadable.append((statement.line, statement.text()))
    return scan


@dataclass
class Criterion:
    """A named requirement in or beside the story's acceptance."""

    name: str
    line: int
    form: str = ""  # "", "sibling" or "typed"
    type_name: str = ""


@dataclass
class StoryShape:
    """What the story body declares, as the checks need it.

    Everything here is read from the lint's own statements, so a story
    written on one line, or two attributes on one line, reads the same
    as the usual layout.
    """

    subjects: List[Statement] = field(default_factory=list)
    roles: List[Statement] = field(default_factory=list)
    meta: Optional[Statement] = None
    prose: List[int] = field(default_factory=list)
    criteria: List[Criterion] = field(default_factory=list)
    order: Dict[int, int] = field(default_factory=dict)
    capability: str = ""
    benefit: str = ""
    meta_values: Dict[str, str] = field(default_factory=dict)

    def names(self) -> List[str]:
        return [criterion.name for criterion in self.criteria]

    @property
    def role(self) -> str:
        """The type name of the first role, or "" when it is untyped."""
        return _type_name(self.roles[0]) if self.roles else ""

    @property
    def status(self) -> str:
        """The status in the @StoryMeta, or "" when it cannot be read."""
        return self.meta_values.get("status", "")


def _type_name(statement: Statement) -> str:
    """The last segment of the type in `: <Type>`, or ""."""
    words, kinds = statement.words, statement.kinds
    for index, word in enumerate(words):
        if (word == ":" and index + 1 < len(words)
                and kinds[index + 1] == "name"):
            end = index + 1
            while (end + 2 < len(words) and words[end + 1] == "::"
                   and kinds[end + 2] == "name"):
                end += 2
            return words[end]
    return ""


def _typed(statement: Statement) -> bool:
    """True when the statement carries `: <Type>`."""
    return bool(_type_name(statement))


def _narrative(shape: StoryShape, words: List[str], kinds: List[str]) -> None:
    """Read `attribute :>> capability = "...";`, or the same for the
    benefit, unescaped and with runs of whitespace collapsed."""
    if (len(words) >= 5 and words[1] == ":>>"
            and words[2] in ("capability", "benefit") and words[3] == "="
            and kinds[4] == "string" and len(words[4]) >= 2
            and words[4].endswith('"')):
        value = sysml_model._unescape(words[4][1:-1])
        setattr(shape, words[2], " ".join(value.split()))


def _meta_values(meta: Statement) -> Dict[str, str]:
    """The `name = value;` pairs of an @StoryMeta body, each value read
    as its last segment, so `StoryStatus::ready` reads as `ready`."""
    values = {}  # type: Dict[str, str]
    for assignment in meta.body:
        words = assignment.words
        if len(words) >= 3 and words[1] == "=":
            values[words[0]] = words[-1]
    return values


def _legacy_values(statement: Statement, docs: List[str]) -> Dict[str, str]:
    """The pairs of a `doc /* StoryMeta: status=ready, ... */` comment,
    the form used before @StoryMeta (finding W9 asks to replace it)."""
    # The comment stripper leaves a marker such as `@@VSEDOC0@@` where
    # the doc body was.
    marker = sysml_model._RE_DOC_MARKER.fullmatch("".join(statement.words[1:]))
    if marker is None or int(marker.group(1)) >= len(docs):
        return {}
    body = " ".join(docs[int(marker.group(1))].split())
    legacy = sysml_model._RE_STORYMETA_DOC.search(body)
    values = {}  # type: Dict[str, str]
    for pair in legacy.group(1).split(",") if legacy else []:
        if "=" in pair:
            name, value = pair.split("=", 1)
            values[name.strip()] = value.strip()
    return values


def _is_acceptance(words: List[str]) -> bool:
    return words[1:3] == [":>>", "acceptance"] or words[1:2] == ["acceptance"]


def _acceptance(shape: StoryShape, statement: Statement) -> None:
    for inner in statement.body:
        words, kinds = inner.head()
        if not words:
            continue
        if words[0] == "doc":
            shape.prose.append(inner.line)
        elif (words[0] == "requirement" and len(words) > 1
              and words[1] != "def"):
            # The name may follow a short name, as in
            # `requirement <'AC1'> firstReading { ... }`.
            name = _declared_name(words, kinds)
            if name < 0:
                continue
            criterion = Criterion(words[name], inner.line)
            if name + 1 < len(words) and words[name + 1] == ":":
                criterion.form = "typed"
                criterion.type_name = (words[name + 2]
                                       if name + 2 < len(words) else "")
            shape.criteria.append(criterion)


def story_shape(body: List[Statement], docs: List[str]) -> StoryShape:
    """What a story body declares. `docs` holds the doc bodies the
    comment stripper took out."""
    shape = StoryShape()
    legacy = {}  # type: Dict[str, str]
    for position, statement in enumerate(body):
        words, kinds = statement.head()
        if not words:
            continue
        shape.order[id(statement)] = position
        if words[0] == "subject":
            shape.subjects.append(statement)
        elif words[0] == "stakeholder":
            shape.roles.append(statement)
        elif words[0] == "attribute":
            _narrative(shape, words, kinds)
        elif words[0] == "doc":
            legacy = legacy or _legacy_values(statement, docs)
        elif words[:2] == ["@", "StoryMeta"]:
            if shape.meta is None:
                shape.meta = statement
                shape.meta_values = _meta_values(statement)
        elif words[0] == "requirement" and len(words) > 1:
            if _is_acceptance(words):
                _acceptance(shape, statement)
            elif (len(words) > 3 and kinds[1] == "name"
                  and words[2] == ":>" and words[3] == "acceptance"):
                shape.criteria.append(
                    Criterion(words[1], statement.line, "sibling"))
    if shape.meta is None:
        shape.meta_values = legacy
    return shape


# ---------------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------------


def _decode(data: bytes, display: str, code: str,
            consequence: str) -> Tuple[Optional[str], List[Finding]]:
    try:
        return data.decode("utf-8"), []
    except UnicodeDecodeError as error:
        line = data[:error.start].count(b"\n") + 1
        return None, [Finding(
            display, line, code,
            "byte 0x{:02x} is not UTF-8 text, so {}. Save the file as "
            "UTF-8".format(data[error.start], consequence),
            "§11.9.1")]


def _read(full: Path, display: str, code: str,
          consequence: str) -> Tuple[Optional[str], List[Finding]]:
    try:
        data = full.read_bytes()
    except OSError as error:
        return None, [Finding(
            display, 1, code,
            "the file cannot be read ({}), so {}".format(
                error.strerror or error, consequence),
            "§11.9.1")]
    return _decode(data, display, code, consequence)


@dataclass
class SysmlFile:
    display: str
    full: Path
    findings: List[Finding]
    scan: StoryScan = field(default_factory=StoryScan)
    # The model reader's view, for the cases and satisfy relationships
    # finding S8 needs. Stories are read from `scan` only.
    model: Optional["sysml_model.Model"] = None


@dataclass
class FeatureFile:
    display: str
    full: Path
    findings: List[Finding]
    feature: Optional["gherkin.Feature"] = None
    lines: List[str] = field(default_factory=list)
    # F6 for the narrative lines, worked out once, or None when they are
    # in order or the file did not parse.
    narrative_order: Optional[Finding] = None

    @property
    def ok(self) -> bool:
        """True when the file parsed into a Feature with no F1 or F2."""
        return self.feature is not None and not any(
            finding.code in ("F1", "F2") for finding in self.findings)

    @property
    def empty(self) -> bool:
        """True when the file was read and parsed with no F1 or F2 but
        holds no Feature, as an empty file or one of blank lines and
        comments alone does. Cucumber accepts such a file, so the parser
        reports nothing, and the story side reports S1."""
        return self.feature is None and not any(
            finding.code in ("F1", "F2") for finding in self.findings)

    def tag_names(self) -> List[str]:
        return [tag.name for tag in self.feature.tags] if self.feature else []


class Workspace:
    """Every file the run reads, each read and parsed once."""

    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.sysml = {}  # type: Dict[Path, SysmlFile]
        self.features = {}  # type: Dict[Path, FeatureFile]

    def sysml_file(self, full: Path, display: str) -> SysmlFile:
        key = full.resolve()
        if key not in self.sysml:
            text, findings = _read(full, display, "S9",
                                   "the stories in it cannot be checked")
            entry = SysmlFile(display, full, findings)
            if text is not None:
                entry.scan = read_stories(text)
                entry.model = sysml_model.Model(
                    project_root=full.parent, model_root="")
                sysml_model.parse_file(full.parent, full, entry.model)
            self.sysml[key] = entry
        return self.sysml[key]

    def feature_file(self, full: Path, display: str) -> FeatureFile:
        key = full.resolve()
        if key not in self.features:
            text, findings = _read(full, display, "F1",
                                   "the feature file cannot be parsed")
            entry = FeatureFile(display, full, findings)
            if text is not None:
                result = gherkin.parse(text, display)
                entry.feature = result.feature
                entry.findings = [_parser_finding(finding)
                                  for finding in result.findings]
                entry.findings.extend(
                    _parser_finding(finding)
                    for finding in gherkin.check_structure(result, display))
                entry.lines = text.split("\n")
                if entry.ok:
                    entry.narrative_order = _narrative_order(entry)
            self.features[key] = entry
        return self.features[key]


def _parser_finding(finding: Finding) -> Finding:
    ref, fix = PARSER_FINDINGS.get(finding.code, (finding.ref, ""))
    message = finding.message
    if fix:
        message = "{}. {}".format(message, fix)
    return Finding(finding.path, finding.line, finding.code, message, ref)


def _display(path: str, *parts: str) -> str:
    return os.path.normpath(os.path.join(path, *parts))


def _lintable(name: str) -> bool:
    return not name.startswith("_") and name.endswith((".sysml", ".feature"))


def _plain(full: Path) -> bool:
    """True for a regular file, or for a link that leads to nothing,
    which reading reports as a finding. A directory search never opens
    a named pipe, a socket or a device, or a link to one, because a read
    could block for ever."""
    return full.is_file() or (full.is_symlink() and not full.exists())


@dataclass
class Scope:
    """The files a run checks, as (full path, display path) pairs."""

    sysml: Dict[Path, Tuple[Path, str]] = field(default_factory=dict)
    features: Dict[Path, Tuple[Path, str]] = field(default_factory=dict)
    directories: Dict[Path, Tuple[Path, str]] = field(default_factory=dict)

    def add_file(self, full: Path, display: str) -> None:
        target = self.sysml if full.name.endswith(".sysml") else self.features
        target.setdefault(full.resolve(), (full, display))

    def add_directory(self, full: Path, display: str) -> None:
        self.directories.setdefault(full.resolve(), (full, display))


def _collect(paths: List[str], project_root: Path) -> Scope:
    scope = Scope()
    for path in paths:
        full = Path(path)
        if not full.is_absolute():
            full = project_root / path
        if not full.exists():
            raise LintError("no such file or directory: {}".format(path))
        if full.is_file():
            if _lintable(full.name):
                scope.add_file(full, _display(path))
                scope.add_directory(full.parent,
                                    _display(os.path.dirname(path) or "."))
            continue
        for root, dirs, names in os.walk(str(full)):
            dirs[:] = sorted(name for name in dirs
                             if not name.startswith("."))
            relative = os.path.relpath(root, str(full))
            found = False
            for name in sorted(names):
                if _lintable(name) and _plain(Path(root) / name):
                    scope.add_file(Path(root) / name,
                                   _display(path, relative, name))
                    found = True
            if found:
                scope.add_directory(Path(root), _display(path, relative))
    return scope


def _directory_files(full: Path, display: str) -> List[Tuple[Path, str]]:
    """The lintable files of one directory. A dangling link is kept, so
    that reading it reports a finding, and a special file is not (see
    _plain)."""
    return [(full / name, _display(display, name))
            for name in sorted(os.listdir(str(full)))
            if _lintable(name) and _plain(full / name)]


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------


def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def read_storymeta(config: Path) -> Dict[str, List[str]]:
    """`required_fields` and `valid_statuses` of the `storymeta` block,
    each as a flow list (`[a, b]`) or a block list (`- a`)."""
    try:
        text = config.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return {}
    found = {}  # type: Dict[str, List[str]]
    inside = False
    key = None  # type: Optional[str]
    for raw in text.splitlines():
        line = re.sub(r"(^|\s)#.*$", "", raw).rstrip()
        if not line.strip():
            continue
        if not line[0].isspace():
            inside = line == "storymeta:"
            key = None
            continue
        if not inside:
            continue
        stripped = line.strip()
        if stripped.startswith("-"):
            if key is not None:
                found[key].append(_unquote(stripped[1:]))
            continue
        match = re.match(r"([A-Za-z_]+):\s*(.*)$", stripped)
        key = None
        if match and match.group(1) in ("required_fields", "valid_statuses"):
            value = match.group(2)
            if value.startswith("["):
                found[match.group(1)] = [
                    _unquote(item) for item in value.strip("[]").split(",")
                    if item.strip()]
            elif not value:
                key = match.group(1)
                found[key] = []
    return found


# ---------------------------------------------------------------------------
# Wellformed rules: section 1.9 and the storymeta fields
# ---------------------------------------------------------------------------


def _check_wellformed(entry: SysmlFile, storymeta: Dict[str, List[str]]
                      ) -> List[Finding]:
    findings = []  # type: List[Finding]
    path = entry.display
    required = storymeta.get("required_fields") or ["status"]
    valid = storymeta.get("valid_statuses") or DEFAULT_STATUSES

    def report(line: int, code: str, message: str, ref: str) -> None:
        findings.append(Finding(path, line, code, message, ref))

    for story in entry.scan.stories:
        sid = story.identifier
        shape = story.shape
        status = shape.status

        # Rule 2: one typed subject, before the role.
        if not shape.subjects:
            report(story.line, "W2",
                   "{} has no subject. Declare `subject :>> system : "
                   "<PartDef>;` before the role".format(sid), "§1.9 rule 2")
        elif len(shape.subjects) > 1:
            report(shape.subjects[1].line, "W2",
                   "{} declares {} subjects. Keep exactly one `subject :>> "
                   "system : <PartDef>;`".format(sid, len(shape.subjects)),
                   "§1.9 rule 2")
        else:
            subject = shape.subjects[0]
            if not _typed(subject):
                report(subject.line, "W2",
                       "the subject of {} has no part definition. Write "
                       "`subject :>> system : <PartDef>;`".format(sid),
                       "§1.9 rule 2")
            if shape.roles and (shape.order[id(subject)]
                                > shape.order[id(shape.roles[0])]):
                report(subject.line, "W2",
                       "the subject of {} comes after its role. Declare the "
                       "subject first".format(sid), "§1.9 rule 2")

        # Rule 3: one role, typed once past backlog. Any status other
        # than backlog is past it, an unreadable one included, as for S8.
        if len(shape.roles) > 1:
            report(shape.roles[1].line, "W3",
                   "{} declares {} roles. Keep exactly one `stakeholder :>> "
                   "role : <PartDef>;`".format(sid, len(shape.roles)),
                   "§1.9 rule 3")
        elif status != "backlog":
            past = ("{} is {}".format(sid, status) if status else
                    "the status of {} cannot be read, so it counts as past "
                    "backlog".format(sid))
            if not shape.roles:
                report(story.line, "W3",
                       "{}, but it has no role. Declare `stakeholder :>> "
                       "role : <PartDef>;` before a story leaves backlog"
                       .format(past), "§1.9 rule 3")
            elif not _typed(shape.roles[0]):
                report(shape.roles[0].line, "W3",
                       "{}, but its role is untyped. Write `stakeholder :>> "
                       "role : <PartDef>;`".format(past), "§1.9 rule 3")

        # Rule 6: the narrative capability and benefit stay.
        for name, value in (("capability", shape.capability),
                            ("benefit", shape.benefit)):
            if not value:
                report(story.line, "W6",
                       "{} has no {}. Keep `attribute :>> {} = \"...\";` "
                       "throughout the story's life".format(sid, name, name),
                       "§1.9 rule 6")

        # Rule 9: @StoryMeta with qualified enumeration values.
        if shape.meta is None:
            report(story.line, "W9",
                   "{} has no @StoryMeta. Apply `@StoryMeta {{ status = "
                   "StoryStatus::backlog; }}` with qualified values, in "
                   "place of any metadata written in a doc comment"
                   .format(sid), "§1.9 rule 9, §1.5")
        else:
            for assignment in shape.meta.body:
                words, kinds = assignment.words, assignment.kinds
                if len(words) < 3 or words[1] != "=":
                    continue
                value = words[2:]
                if "::" in value or (len(value) == 1 and kinds[2] in (
                        "number", "string")):
                    continue
                report(assignment.line, "W9",
                       "`{} = {}` in the @StoryMeta of {} is not qualified. "
                       "Write `{} = {}::{};`".format(
                           words[0], " ".join(value), sid, words[0],
                           ENUMERATIONS.get(words[0], "<Enumeration>"),
                           " ".join(value)), "§1.9 rule 9, §1.5")

        # Storymeta fields: status always, the rest once past backlog.
        # Without a status, which fields apply is unknown, so the missing
        # status is the one finding.
        line = shape.meta.line if shape.meta is not None else story.line
        if not status:
            report(line, "W10",
                   "{} has no status. Add `status = StoryStatus::backlog;` "
                   "or its actual status to the @StoryMeta".format(sid),
                   "§1.5")
        else:
            if status not in valid:
                report(line, "W10",
                       "{} has the status {}, which is not one of {}. Use "
                       "one of the valid statuses".format(
                           sid, status, ", ".join(valid)), "§1.5, §0.10.3")
            if status != "backlog":
                missing = [name for name in required
                           if name != "status"
                           and name not in shape.meta_values]
                for name in missing:
                    report(line, "W10",
                           "{} is {} but its @StoryMeta has no {}. The "
                           "project requires {} once a story leaves "
                           "backlog (storymeta in .iso-config.yaml)".format(
                               sid, status, name, ", ".join(required)),
                           "§1.5, §0.10.3")
    return findings


# ---------------------------------------------------------------------------
# Gherkin rules: S1 to S9 and F1 to F10
# ---------------------------------------------------------------------------


def _description_lines(entry: FeatureFile) -> List[int]:
    """The line number of each description line of the Feature."""
    numbers = []  # type: List[int]
    index = entry.feature.line
    for text in entry.feature.description:
        while (index < len(entry.lines)
               and entry.lines[index].strip() != text):
            index += 1
        numbers.append(index + 1)
        index += 1
    return numbers


def _criterion_tags_of(tags: List["gherkin.Tag"]) -> List["gherkin.Tag"]:
    return [tag for tag in tags if tag.name.startswith("@AC_")]


def _criterion_tags(scenario) -> List["gherkin.Tag"]:
    return _criterion_tags_of(scenario.tags)


def _parts(full: Path, project_root: Path) -> Tuple[str, ...]:
    """The parts of the resolved path, relative to the project root when
    it lies inside it."""
    resolved = full.resolve()
    try:
        return resolved.relative_to(project_root.resolve()).parts
    except ValueError:
        return resolved.parts


def _in_stories_directory(entry: FeatureFile, project_root: Path) -> bool:
    return "stories" in _parts(entry.full, project_root)[:-1]


def _narrative_order(entry: FeatureFile) -> Optional[Finding]:
    description = entry.feature.description
    lines = _description_lines(entry)
    expected = (("As a ", "As an "), ("I want ",), ("So that ",))
    for index, prefixes in enumerate(expected):
        if index < len(description) and description[index].startswith(
                prefixes):
            continue
        if index < len(description):
            line = lines[index]
            found = "line {} reads '{}'".format(line, description[index])
        else:
            line = lines[-1] if lines else entry.feature.line
            found = "the description has {} line{}".format(
                len(description), "" if len(description) == 1 else "s")
        return Finding(
            entry.display, line, "F6",
            "the Feature description opens with the narrative lines "
            "'As a <role>', 'I want <capability>' and 'So that <benefit>', "
            "in that order, but {}. Write the three lines first"
            .format(found), "§11.2.2")
    return None


def _check_feature(entry: FeatureFile, project_root: Path) -> List[Finding]:
    """F1 to F10 for one feature file, without its story."""
    findings = list(entry.findings)
    if not _in_stories_directory(entry, project_root):
        findings.append(Finding(
            entry.display, 1, "F10",
            "{} is not under a stories/ directory. A story and its feature "
            "file belong together in a stories/ directory, so move the "
            "story there first if it is declared elsewhere, then move this "
            "file beside the .sysml file that declares it".format(
                entry.full.name), "§11.2.1"))
    if not entry.ok:
        return findings
    feature = entry.feature
    tags = feature.tags
    if len(tags) != 1:
        findings.append(Finding(
            entry.display, feature.line, "F3",
            "the Feature carries {} tags. It carries exactly one, "
            "@<StoryIdentifier>, and no other".format(len(tags)),
            "§11.2.2"))
    elif not _RE_IDENTIFIER.fullmatch(tags[0].name[1:]):
        findings.append(Finding(
            entry.display, tags[0].line, "F3",
            "the tag {} is not a story identifier. Tag the Feature with "
            "@<StoryIdentifier>, the identifier matching "
            "^[A-Za-z_][A-Za-z0-9_]*$".format(tags[0].name), "§11.2.1"))
    elif tags[0].name[1:] + ".feature" != entry.full.name:
        findings.append(Finding(
            entry.display, tags[0].line, "F4",
            "the file name {} differs from the story tag {}. Name the file "
            "{}.feature, or correct the tag".format(
                entry.full.name, tags[0].name, tags[0].name[1:]),
            "§11.2.1"))
    seen = {}  # type: Dict[str, int]
    for scenario in feature.all_scenarios():
        criterion_tags = _criterion_tags(scenario)
        if not criterion_tags:
            findings.append(Finding(
                entry.display, scenario.line, "F5",
                "scenario '{}' has no @AC_<name> tag. Tag it with the name "
                "of the criterion it states".format(scenario.name),
                "§11.2.3"))
            continue
        if len(criterion_tags) > 1:
            findings.append(Finding(
                entry.display, criterion_tags[1].line, "F5",
                "scenario '{}' carries {} @AC_ tags. A scenario states one "
                "criterion, so keep one tag and move the other criterion "
                "to a scenario of its own".format(
                    scenario.name, len(criterion_tags)), "§11.2.3"))
        for tag in criterion_tags:
            name = tag.name[len("@AC_"):]
            if not _RE_CRITERION.fullmatch(name):
                findings.append(Finding(
                    entry.display, tag.line, "F5",
                    "{} is not lowerCamelCase. Name the criterion to match "
                    "^[a-z][A-Za-z0-9]*$, for example @AC_firstReading, "
                    "and rename the nested requirement to match"
                    .format(tag.name), "§11.2.3"))
            if name in seen:
                findings.append(Finding(
                    entry.display, tag.line, "F5",
                    "{} is already used by the scenario at line {}. "
                    "Criterion names are unique within the Feature, so "
                    "rename one criterion".format(tag.name, seen[name]),
                    "§11.2.3"))
            else:
                seen[name] = tag.line
    findings.extend(_misplaced_criterion_tags(entry))
    if entry.narrative_order is not None:
        findings.append(entry.narrative_order)
    return findings


def _misplaced_criterion_tags(entry: FeatureFile) -> List[Finding]:
    """F5 for an @AC_ tag on the Feature, a Rule or an Examples block,
    none of which states a criterion of its own (§11.2.4)."""
    feature = entry.feature
    scenario_target = "the scenario that states the criterion"
    places = [(feature.tags, "the Feature", "A Feature", scenario_target)]
    for rule in feature.rules:
        places.append((rule.tags, "the Rule '{}'".format(rule.name),
                       "A Rule", scenario_target))
    for scenario in feature.all_scenarios():
        for examples in scenario.examples:
            places.append((examples.tags,
                           "an Examples block of '{}'".format(scenario.name),
                           "An Examples block", "its Scenario Outline"))
    return [Finding(entry.display, tag.line, "F5",
                    "{} is on {}. {} states no criterion of its own, so "
                    "move the tag to {}".format(tag.name, where, kind, target),
                    "§11.2.3, §11.2.4")
            for tags, where, kind, target in places
            for tag in _criterion_tags_of(tags)]


def _words(text: str) -> str:
    return " ".join(text.split())


def _check_narrative(entry: FeatureFile, sid: str,
                     story: StoryShape) -> List[Finding]:
    """S6: the narrative lines against the story's role, capability and
    benefit. Run only when the order (F6) is right."""
    findings = []  # type: List[Finding]
    description = entry.feature.description
    lines = _description_lines(entry)
    role_line, want_line, benefit_line = description[:3]
    article = "As an " if role_line.startswith("As an ") else "As a "
    role = role_line[len(article):]
    if story.role and ("".join(role.split()).lower()
                       != story.role.lower()):
        findings.append(Finding(
            entry.display, lines[0], "S6",
            "'{}' does not name the role of {}, which is {}. Write "
            "'As a <role>' with the role's part definition name, spaces "
            "and case aside".format(role_line, sid, story.role),
            "§11.2.2"))
    want = _words(want_line[len("I want "):])
    wanted = [want]
    if want.startswith("to "):
        wanted.append(want[len("to "):])
    if story.capability and story.capability not in wanted:
        findings.append(Finding(
            entry.display, lines[1], "S6",
            "'{}' does not repeat the capability of {}, \"{}\". Write "
            "'I want to {}' or 'I want {}'".format(
                want_line, sid, story.capability, story.capability,
                story.capability), "§11.2.2"))
    benefit = _words(benefit_line[len("So that "):])
    if story.benefit and story.benefit != benefit:
        findings.append(Finding(
            entry.display, lines[2], "S6",
            "'{}' does not repeat the benefit of {}, \"{}\". Write "
            "'So that {}'".format(benefit_line, sid, story.benefit,
                                  story.benefit), "§11.2.2"))
    return findings


@dataclass
class World:
    """Cases and satisfy relationships across the model root and the
    files linted, keyed by story identifier."""

    verified: Dict[str, set] = field(default_factory=dict)
    satisfied: Dict[str, List[Tuple[str, str]]] = field(default_factory=dict)

    def add(self, entry: SysmlFile, known: set) -> None:
        """Record the cases and satisfy relationships of one file. A
        verify target is split with `known`, the story identifiers the
        model declares, so `P::story_1` reaches the story `story_1`."""
        if entry.model is None:
            return
        for case in entry.model.cases:
            for target, member in case.resolved(known):
                self.verified.setdefault(target, set()).add(member)
        for satisfaction in entry.model.satisfactions:
            self.satisfied.setdefault(satisfaction.requirement, []).append(
                (satisfaction.element, entry.display))

    def covers(self, sid: str, criterion: str) -> bool:
        members = self.verified.get(sid, set())
        return bool(members & {"", "acceptance",
                               "acceptance." + criterion})


def _world(workspace: Workspace, scope_files: List[SysmlFile]) -> World:
    world = World()
    entries = list(scope_files)
    try:
        model_root = sysml_model.find_model_root(workspace.project_root)
    except sysml_model.ModelError:
        model_root = None
    if model_root is not None:
        for root, dirs, names in os.walk(str(model_root)):
            dirs[:] = sorted(name for name in dirs
                             if not name.startswith("."))
            for name in sorted(names):
                full = Path(root) / name
                if (name.endswith(".sysml") and not name.startswith("_")
                        and _plain(full)):
                    display = os.path.relpath(
                        str(full), str(workspace.project_root))
                    entries.append(workspace.sysml_file(full, display))
    unique = list({id(entry): entry for entry in entries}.values())
    known = set()
    for entry in unique:
        known.update(story.identifier for story in entry.scan.stories)
        if entry.model is not None:
            known.update(story.identifier for story in entry.model.stories)
    for entry in unique:
        world.add(entry, known)
    return world


def _standing(sid: str, status: str) -> str:
    """The story's status as S8 reports it, saying why the strictest row
    applies when the status cannot be read or is not ranked."""
    if not status:
        return ("{} is held to the strictest row of §11.4 because its "
                "status cannot be read".format(sid))
    if status not in STATUS_RANK:
        return ("{} is held to the strictest row of §11.4 because the table "
                "does not rank its status {}".format(sid, status))
    return "{} is {}".format(sid, status)


def _check_story(story: StoryBlock, entry: SysmlFile, directory: str,
                 features: Dict[str, FeatureFile], world: World
                 ) -> List[Finding]:
    """S1 to S8 for one story in its directory."""
    findings = []  # type: List[Finding]
    path = entry.display
    sid = story.identifier
    shape = story.shape
    status = shape.status
    rank = STATUS_RANK.get(status, STRICTEST)
    name = sid + ".feature"
    feature = features.get(name)

    describing = sorted(other.full.name for other in features.values()
                        if other.ok and "@" + sid in other.tag_names())
    if len(describing) > 1:
        findings.append(Finding(
            path, story.line, "S2",
            "{} is described by {} feature files ({}). Keep {} alone and "
            "merge the others into it".format(
                sid, len(describing), ", ".join(describing), name),
            "§11.2.1"))
    if feature is None:
        findings.append(Finding(
            path, story.line, "S1",
            "{} has no feature file. Write {}, tagged @{} and opening "
            "with the story's narrative lines".format(
                sid, _display(directory, name), sid), "§11.2.1, §11.4"))
    elif feature.empty:
        findings.append(Finding(
            path, story.line, "S1",
            "{} holds no Feature. Write the Feature, tagged @{} and "
            "opening with the story's narrative lines".format(name, sid),
            "§11.2.2, §11.4"))
    elif feature.ok and "@" + sid not in feature.tag_names():
        findings.append(Finding(
            path, story.line, "S1",
            "{} does not carry the tag @{}. Tag its Feature with @{}"
            .format(name, sid, sid), "§11.2.2"))
    if shape.prose:
        findings.append(Finding(
            path, shape.prose[0], "S3",
            "{} keeps acceptance prose outside a named criterion, the form "
            "used before 5.0.0. Formalise its Given/When/Then text as "
            "scenarios in {} and nest one `requirement <name> {{ doc /* "
            "... */ }}` per scenario in `requirement :>> acceptance`"
            .format(sid, name), "§11.3.1"))
    for criterion in shape.criteria:
        if criterion.form == "sibling":
            findings.append(Finding(
                path, criterion.line, "S7",
                "criterion {} of {} is declared beside the acceptance, as "
                "`requirement {} :> acceptance`. Nest it inside "
                "`requirement :>> acceptance` as `requirement {} {{ ... }}`"
                .format(criterion.name, sid, criterion.name, criterion.name),
                "§11.3.1"))
        elif criterion.form == "typed":
            findings.append(Finding(
                path, criterion.line, "S7",
                "criterion {} of {} is typed by {}. Criteria are untyped, "
                "so write `requirement {} {{ ... }}`".format(
                    criterion.name, sid, criterion.type_name or "a definition",
                    criterion.name), "§11.3.1"))

    # The scenarios of the feature file, none for one that holds no
    # Feature, or None when there is no file or it does not parse.
    scenarios = None  # type: Optional[list]
    tags = []  # type: List[Tuple[str, int]]
    if feature is not None and feature.empty:
        scenarios = []
    if feature is not None and feature.ok:
        scenarios = feature.feature.all_scenarios()
        tags = [(tag.name[len("@AC_"):], tag.line)
                for scenario in scenarios
                for tag in _criterion_tags(scenario)]
        tag_names = {tag for tag, _line in tags}
        for criterion in shape.criteria:
            if criterion.name not in tag_names:
                findings.append(Finding(
                    path, criterion.line, "S4",
                    "criterion {} of {} has no scenario tagged @AC_{} in "
                    "{}. Write the scenario, or remove the criterion"
                    .format(criterion.name, sid, criterion.name, name),
                    "§11.3.1"))
        reported = set()
        for tag, line in tags:
            if tag not in shape.names() and tag not in reported:
                reported.add(tag)
                findings.append(Finding(
                    feature.display, line, "S5",
                    "@AC_{} has no matching criterion in {}. Nest "
                    "`requirement {} {{ doc /* ... */ }}` in its "
                    "`requirement :>> acceptance`, or remove the tag"
                    .format(tag, sid, tag), "§11.3.1"))
        if feature.narrative_order is None:
            findings.extend(_check_narrative(feature, sid, shape))
    if scenarios is not None and rank >= 1 and not tags:
        findings.append(Finding(
            path, story.line, "S8",
            "{} has no scenario tagged @AC_<name>, and {}. Write at "
            "least one scenario, or set the status to backlog".format(
                name, _standing(sid, status)), "§11.4"))

    if rank >= 2:
        for criterion in shape.criteria:
            if not world.covers(sid, criterion.name):
                findings.append(Finding(
                    path, criterion.line, "S8",
                    "criterion {} of {} is reached by no verification or "
                    "validation case, and {}. Add `verify {}.acceptance.{};` "
                    "to a case objective, a stub is enough".format(
                        criterion.name, sid, _standing(sid, status), sid,
                        criterion.name), "§11.4, §11.3.3"))

    satisfactions = world.satisfied.get(sid, [])
    no_scenarios = feature is None or (scenarios is not None
                                       and not scenarios)
    if satisfactions and no_scenarios:
        element, source = satisfactions[0]
        findings.append(Finding(
            path, story.line, "S8",
            "`satisfy {} by {}` in {} allocates design to a story with no "
            "scenarios. Write the scenarios in {} first".format(
                sid, element, source, name), "§11.4"))
    return findings


def _check_directory(workspace: Workspace, full: Path, display: str,
                     world: World) -> List[Finding]:
    findings = []  # type: List[Finding]
    sysml_entries = []  # type: List[SysmlFile]
    features = {}  # type: Dict[str, FeatureFile]
    for file_full, file_display in _directory_files(full, display):
        if file_full.name.endswith(".sysml"):
            sysml_entries.append(
                workspace.sysml_file(file_full, file_display))
        else:
            entry = workspace.feature_file(file_full, file_display)
            features[file_full.name] = entry
            findings.extend(_check_feature(entry, workspace.project_root))
    # Stories are paired with their feature files in stories directories
    # alone (§11.2.1). A story declared elsewhere is not checked, and a
    # feature file beside it draws F10.
    if "stories" not in _parts(full, workspace.project_root):
        return findings
    for entry in sysml_entries:
        for line, text in entry.scan.unreadable:
            findings.append(Finding(
                entry.display, line, "S9",
                "`{}` types or specialises UserStory in a form the story "
                "tooling cannot read, so the story is not checked. Declare "
                "it as `requirement <ID> : UserStory {{ ... }}`".format(text),
                "§1.9 rule 1, §11.9.1"))
        for story in entry.scan.stories:
            findings.extend(
                _check_story(story, entry, display, features, world))
    return findings


# ---------------------------------------------------------------------------
# Entry points
# ---------------------------------------------------------------------------


def _sort_key(finding: Finding):
    number = int(finding.code[1:]) if finding.code[1:].isdigit() else 0
    return (finding.path, finding.line, finding.code[:1], number,
            finding.message)


def _sorted_once(findings: List[Finding]) -> List[Finding]:
    """The findings sorted, each once. A file that two directories in
    scope reach, one of them through a link, is read once but checked
    in each directory, so its findings would otherwise repeat."""
    unique = {}  # type: Dict[Tuple[str, int, str, str, str], Finding]
    for finding in findings:
        unique.setdefault((finding.path, finding.line, finding.code,
                           finding.message, finding.ref), finding)
    return sorted(unique.values(), key=_sort_key)


def lint_paths(paths: List[str], only: Optional[str],
               project_root: Path) -> List[Finding]:
    """Findings for `paths`, sorted by path, line and code.

    Relative paths are taken from `project_root`, which is also where the
    model root and `.iso-config.yaml` are looked for. Raise LintError for
    a missing path, an unknown mode, or a missing gherkin.py or
    sysml_model.py.
    """
    if IMPORT_ERROR is not None:
        raise LintError(IMPORT_ERROR)
    if only is not None and only not in MODES:
        raise LintError("unknown rule set {}, expected one of {}".format(
            only, ", ".join(MODES)))
    project_root = Path(project_root)
    scope = _collect(paths, project_root)
    workspace = Workspace(project_root)
    findings = []  # type: List[Finding]

    if only == "syntax":
        # A feature file's own findings are the parser's: F1, F2, F7, F8
        # and F9.
        for full, display in scope.features.values():
            findings.extend(workspace.feature_file(full, display).findings)
        return sorted(findings, key=_sort_key)

    if only in (None, "wellformed"):
        storymeta = read_storymeta(project_root / CONFIG)
        for full, display in scope.sysml.values():
            findings.extend(_check_wellformed(
                workspace.sysml_file(full, display), storymeta))

    if only in (None, "gherkin"):
        in_directories = [
            workspace.sysml_file(file_full, file_display)
            for full, display in scope.directories.values()
            for file_full, file_display in _directory_files(full, display)
            if file_full.name.endswith(".sysml")]
        world = _world(workspace, in_directories)
        for full, display in scope.directories.values():
            findings.extend(_check_directory(workspace, full, display, world))
        # A model file that cannot be read or decoded is S9, which is the
        # gherkin gate's finding alone, so that no finding carries two
        # dispositions. The wellformed rule set skips such a file.
        for entry in in_directories:
            findings.extend(entry.findings)
    return _sorted_once(findings)


def _environment_error(message: str) -> int:
    """Write the message on one line of standard error, for exit 2."""
    sys.stderr.write("story-wellformed.py: {}\n".format(
        " ".join(message.split())))
    return 2


def _drop_stdout() -> None:
    """Point standard output at the null device, so that the flush at
    exit cannot fail again on the pipe or file that just failed."""
    try:
        null = os.open(os.devnull, os.O_WRONLY)
        try:
            os.dup2(null, sys.stdout.fileno())
        finally:
            os.close(null)
    except (OSError, ValueError):
        pass


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        prog="story-wellformed.py",
        description="Check user stories against their Gherkin feature "
                    "files (methodology sections 1.9 and 11).")
    parser.add_argument("--only", choices=MODES,
                        help="run one rule set (default: wellformed and "
                             "gherkin)")
    parser.add_argument("--format", choices=("text", "json"), default="text",
                        help="output format (default: text)")
    parser.add_argument("paths", nargs="+", metavar="PATH",
                        help=".sysml file, .feature file or directory")
    args = parser.parse_args(argv)
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="backslashreplace")
    try:
        findings = lint_paths(args.paths, args.only, Path.cwd())
    except (LintError, OSError) as error:
        return _environment_error(str(error))
    except Exception as error:  # A defect must not read as findings.
        return _environment_error("unexpected error, {}: {}".format(
            type(error).__name__, error))
    try:
        if args.format == "json":
            print(json.dumps([finding.as_dict() for finding in findings],
                             indent=2))
        else:
            for finding in findings:
                print(finding.format())
        sys.stdout.flush()
    except OSError as error:
        # BrokenPipeError when the reader has gone, as with `| head`, or
        # another OSError when the device fails, such as a full disk.
        _drop_stdout()
        return _environment_error("cannot write the findings ({})".format(
            error.strerror or error))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
