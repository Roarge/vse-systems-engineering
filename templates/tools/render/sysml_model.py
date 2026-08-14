#!/usr/bin/env python3
"""Shared reader for the SysML 2.0 model behind the section 9.8 renderers.

The three renderer scripts in this directory (traceability-matrix.py,
stakeholder-reqs-doc.py and system-reqs-doc.py) need the same view of the
model, so the reading happens once here and each renderer is left with
formatting alone.

Scope and method
----------------
This is a tolerant line-oriented reader, not a SysML 2.0 compiler. It uses
the Python standard library only, so it runs inside a git hook and on a
bare CI runner with no licence and no install step. A project that adopts
a full SysML 2.0 API implementation replaces these scripts at the swap
point documented in methodology/iso-29110-hooks-guide.md section 3.1.

Constructs recognised:

* `requirement def <ID> :> UserStory { ... }`, with `subject <n> : <Type>`,
  `stakeholder <n> : <Role>`, `attribute :>> capability = "..."`,
  `attribute :>> benefit = "..."`, `frame <n> : <Concern>`,
  `requirement acceptance[n] { doc /* ... */ }`, and
  `require constraint <name>`.
* `connection <name> : RequirementDerivation::derivations { end ::> A;
  end ::> B; }`, read as original then derived per methodology section
  5.4.1, corroborated by the `#derive` annotation on the derived story.
* `verification def <ID> { doc /* ... */ objective { verify <ID>::<member>;
  } }`, classified as a verification case or a validation case by
  identifier prefix and, failing that, by the directory the file sits in.
* `satisfy <requirement> by <element>;`, recorded when present.

Anything else is skipped rather than reported. The renderers document what
the model states, and a reader that refused unfamiliar syntax would block
the very commits the hooks exist to encourage.

Determinism
-----------
Contract 3 (methodology/iso-29110-hooks-guide.md section 4.4) compares the
regenerated artefact against the committed copy byte for byte, so every
reading step is ordered. Files are visited in sorted relative path order,
and elements keep their declaration order within a file. No output carries
a timestamp, a host name, or an absolute path.
"""

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Directories searched for the model, in order, relative to the project
# root. This mirrors the .iso-config.yaml discovery convention used by the
# shipped git hooks.
MODEL_ROOTS = ("model", "engineering/model")

# Placeholder written in place of a captured `doc /* ... */` body so that
# the body survives comment stripping without disturbing line structure.
_DOC_MARKER_TEMPLATE = "@@VSEDOC{}@@"
_RE_DOC_MARKER = re.compile(r"@@VSEDOC(\d+)@@")

_RE_TRAILING_DOC = re.compile(r"(?:^|[^A-Za-z0-9_])doc\s*$")

_RE_STORY = re.compile(
    r"\brequirement\s+def\s+(?:<[^>]*>\s*)?"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*:>\s*([A-Za-z_][A-Za-z0-9_:]*)"
)
_RE_CASE = re.compile(
    r"\bverification\s+def\s+(?:<[^>]*>\s*)?([A-Za-z_][A-Za-z0-9_]*)"
)
_RE_CONNECTION = re.compile(
    r"\bconnection\s+(?:<[^>]*>\s*)?([A-Za-z_][A-Za-z0-9_]*)\s*:\s*"
    r"([A-Za-z_][A-Za-z0-9_:]*)"
)
_RE_DERIVATION_TYPE = re.compile(r"(?:^|::)[Dd]erivations?$")
_RE_ACCEPTANCE = re.compile(r"\brequirement\s+acceptance\s*(\[[^\]]*\])?")
_RE_CONSTRAINT = re.compile(r"\brequire\s+constraint\s+([A-Za-z_][A-Za-z0-9_]*)")
_RE_SUBJECT = re.compile(
    r"\bsubject\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_:]*)"
)
_RE_STAKEHOLDER = re.compile(
    r"\bstakeholder\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_:]*)"
)
_RE_NARRATIVE = re.compile(
    r"\battribute\s*:>>\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\"((?:[^\"\\]|\\.)*)\""
)
_RE_FRAME = re.compile(
    r"\bframe\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_:]*)"
)
_RE_END = re.compile(r"\bend\s*::>\s*([A-Za-z_][A-Za-z0-9_:]*)")
_RE_VERIFY = re.compile(r"\bverify\s+([A-Za-z_][A-Za-z0-9_:]*)")
_RE_SATISFY = re.compile(
    r"\bsatisfy\s+(?:requirement\s+)?([A-Za-z_][A-Za-z0-9_:]*)\s+by\s+"
    r"([A-Za-z_][A-Za-z0-9_:.]*)"
)

# Longest logical line the reader will accumulate before giving up on
# joining continuations. A model file that trips this limit is malformed,
# and the reader keeps going rather than looping.
_MAX_LOGICAL_LINE = 4000


class ModelError(Exception):
    """Raised when the model cannot be located or read."""


@dataclass
class DocBlock:
    """A `doc /* ... */` body, normalised into paragraphs."""

    paragraphs: List[str] = field(default_factory=list)

    @property
    def text(self) -> str:
        return "\n\n".join(self.paragraphs)


@dataclass
class Acceptance:
    """One `requirement acceptance[n]` sub-requirement of a story."""

    label: str
    doc: DocBlock = field(default_factory=DocBlock)


@dataclass
class Constraint:
    """One `require constraint <name>` clause of a story."""

    name: str
    doc: DocBlock = field(default_factory=DocBlock)


@dataclass
class Story:
    """A `requirement def <ID> :> UserStory` element."""

    identifier: str
    source: str
    kind: str
    subject: str = ""
    role: str = ""
    capability: str = ""
    benefit: str = ""
    derive_annotation: bool = False
    concerns: List[str] = field(default_factory=list)
    acceptances: List[Acceptance] = field(default_factory=list)
    constraints: List[Constraint] = field(default_factory=list)
    doc: DocBlock = field(default_factory=DocBlock)

    @property
    def constraint_names(self) -> List[str]:
        return [constraint.name for constraint in self.constraints]


@dataclass
class Case:
    """A `verification def <ID>` element, verification or validation."""

    identifier: str
    source: str
    kind: str
    subject: str = ""
    verifies: List[Tuple[str, str]] = field(default_factory=list)
    doc: DocBlock = field(default_factory=DocBlock)

    def targets(self) -> List[str]:
        """Story identifiers this case verifies, in declaration order."""
        seen = []
        for target, _member in self.verifies:
            if target not in seen:
                seen.append(target)
        return seen

    def covers_acceptance(self, identifier: str) -> bool:
        """True when the case verifies the story's acceptance.

        A case that names only a constraint member verifies that
        constraint, not the acceptance criteria, so it does not count as
        acceptance coverage. A case that names the story with no member
        verifies the whole story, acceptance included.
        """
        for target, member in self.verifies:
            if target != identifier:
                continue
            if member in ("", "acceptance"):
                return True
        return False


@dataclass
class Derivation:
    """A `RequirementDerivation::derivations` connection between stories."""

    name: str
    source: str
    original: str = ""
    derived: str = ""


@dataclass
class Satisfaction:
    """A `satisfy <requirement> by <element>` relation."""

    requirement: str
    element: str
    source: str


@dataclass
class Model:
    """Everything the renderers read from one project's model tree."""

    project_root: Path
    model_root: str
    files: List[str] = field(default_factory=list)
    stories: List[Story] = field(default_factory=list)
    cases: List[Case] = field(default_factory=list)
    derivations: List[Derivation] = field(default_factory=list)
    satisfactions: List[Satisfaction] = field(default_factory=list)

    def stories_of_kind(self, kind: str) -> List[Story]:
        return [story for story in self.stories if story.kind == kind]

    def cases_of_kind(self, kind: str) -> List[Case]:
        return [case for case in self.cases if case.kind == kind]

    def story(self, identifier: str) -> Optional[Story]:
        for story in self.stories:
            if story.identifier == identifier:
                return story
        return None

    def derived_from(self, identifier: str) -> List[str]:
        """System stories derived from the named story, in model order."""
        result = []
        for derivation in self.derivations:
            if derivation.original == identifier and derivation.derived:
                if derivation.derived not in result:
                    result.append(derivation.derived)
        return result

    def originals_of(self, identifier: str) -> List[str]:
        """Stories the named story derives from, in model order."""
        result = []
        for derivation in self.derivations:
            if derivation.derived == identifier and derivation.original:
                if derivation.original not in result:
                    result.append(derivation.original)
        return result

    def cases_verifying(self, identifier: str, kind: str = "") -> List[Case]:
        """Cases naming the story as a verify target, in model order."""
        result = []
        for case in self.cases:
            if kind and case.kind != kind:
                continue
            if identifier in case.targets():
                result.append(case)
        return result

    def elements_satisfying(self, identifier: str) -> List[str]:
        result = []
        for satisfaction in self.satisfactions:
            if satisfaction.requirement == identifier:
                if satisfaction.element not in result:
                    result.append(satisfaction.element)
        return result


# ---------------------------------------------------------------------------
# Text scanning
# ---------------------------------------------------------------------------


def _strip_comments(text: str) -> Tuple[str, List[str]]:
    """Remove comments, keeping `doc` bodies and the line structure.

    Line comments disappear. Block comments disappear too, except when the
    preceding token is `doc`, in which case the body is captured and a
    marker takes its place so the parser can attach it to the construct
    being read. The newlines inside every block comment are preserved so
    that line-oriented reading downstream is not thrown off.
    """
    docs: List[str] = []
    out: List[str] = []
    index = 0
    length = len(text)
    in_string = False
    while index < length:
        char = text[index]
        following = text[index + 1] if index + 1 < length else ""
        if in_string:
            out.append(char)
            if char == "\\" and index + 1 < length:
                out.append(text[index + 1])
                index += 2
                continue
            if char == '"':
                in_string = False
            index += 1
            continue
        if char == '"':
            in_string = True
            out.append(char)
            index += 1
            continue
        if char == "/" and following == "/":
            while index < length and text[index] != "\n":
                index += 1
            continue
        if char == "/" and following == "*":
            end = text.find("*/", index + 2)
            if end == -1:
                body = text[index + 2:]
                index = length
            else:
                body = text[index + 2:end]
                index = end + 2
            if _RE_TRAILING_DOC.search("".join(out[-24:])):
                docs.append(body)
                out.append(_DOC_MARKER_TEMPLATE.format(len(docs) - 1) + ";")
            out.append("\n" * body.count("\n"))
            continue
        out.append(char)
        index += 1
    return "".join(out), docs


def _is_complete(buffer: str) -> bool:
    """True when the accumulated text forms a whole logical line."""
    if not buffer:
        return True
    if buffer.endswith((";", "{", "}")):
        return True
    if buffer.startswith("#"):
        return True
    return len(buffer) >= _MAX_LOGICAL_LINE


def _logical_lines(text: str) -> List[str]:
    """Join continuation lines so each entry is one statement.

    A narrative attribute frequently wraps, as in

        attribute :>> capability =
            "deliver each reading within a bounded latency";

    and the two physical lines have to be read as one.
    """
    lines: List[str] = []
    buffer = ""
    for physical in text.replace("\r\n", "\n").replace("\r", "\n").split("\n"):
        stripped = physical.strip()
        if not stripped:
            if buffer:
                lines.append(buffer)
                buffer = ""
            continue
        buffer = (buffer + " " + stripped) if buffer else stripped
        if _is_complete(buffer):
            lines.append(buffer)
            buffer = ""
    if buffer:
        lines.append(buffer)
    return lines


def _brace_delta(line: str) -> int:
    """Net brace depth change across a line, ignoring string literals."""
    delta = 0
    in_string = False
    escaped = False
    for char in line:
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char == "{":
            delta += 1
        elif char == "}":
            delta -= 1
    return delta


def _paragraphs(body: str) -> List[str]:
    """Normalise a doc body into paragraphs separated by blank lines."""
    paragraphs: List[str] = []
    current: List[str] = []
    for raw in body.replace("\r\n", "\n").replace("\r", "\n").split("\n"):
        stripped = raw.strip()
        if stripped:
            current.append(stripped)
        elif current:
            paragraphs.append(" ".join(current))
            current = []
    if current:
        paragraphs.append(" ".join(current))
    return [" ".join(paragraph.split()) for paragraph in paragraphs]


_STRING_ESCAPES = {
    "\\": "\\",
    '"': '"',
    "'": "'",
    "n": "\n",
    "t": "\t",
    "r": "\r",
    "b": "\b",
    "f": "\f",
}


def _unescape(literal: str) -> str:
    """Resolve the escape sequences inside a string literal.

    A capability or benefit that quotes the user interface, as in
    `"select \\"Acknowledge all\\""`, has to reach the rendered document
    with the quotation marks the engineer wrote and without the backslashes
    the grammar needed.
    """
    out: List[str] = []
    index = 0
    length = len(literal)
    while index < length:
        char = literal[index]
        if char == "\\" and index + 1 < length:
            following = literal[index + 1]
            out.append(_STRING_ESCAPES.get(following, following))
            index += 2
            continue
        out.append(char)
        index += 1
    return "".join(out)


def _last_segment(qualified: str) -> str:
    return qualified.split("::")[-1]


def _split_target(qualified: str) -> Tuple[str, str]:
    """Split a verify target into the story identifier and the member.

    Story identifiers start with a capital under the methodology naming
    conventions (US_, SYS_, VC_, VAL_ per section 1.6), and members such as
    `acceptance` or `dashboardSla` start lower case. The distinction is
    what separates `SYS_001_X::acceptance` from a plain `SYS_001_X`.
    """
    segments = [segment for segment in qualified.split("::") if segment]
    if not segments:
        return "", ""
    last = segments[-1]
    if len(segments) >= 2 and last[:1].islower():
        return segments[-2], last
    return last, ""


# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------


def _story_kind(relative_path: str, identifier: str) -> str:
    lowered = relative_path.lower()
    if "stories/system" in lowered:
        return "system"
    if "stories/stakeholder" in lowered:
        return "stakeholder"
    if identifier.upper().startswith("SYS_"):
        return "system"
    return "stakeholder"


def _case_kind(relative_path: str, identifier: str) -> str:
    upper = identifier.upper()
    if upper.startswith("VAL"):
        return "validation"
    if upper.startswith("VC"):
        return "verification"
    if "validation-cases" in relative_path.lower():
        return "validation"
    return "verification"


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------


class _Frame:
    """One open brace block the reader is currently inside."""

    def __init__(self, kind: str, depth: int, data=None):
        self.kind = kind
        self.depth = depth
        self.data = data


def _nearest(stack: List[_Frame], kind: str):
    for frame in reversed(stack):
        if frame.kind == kind:
            return frame.data
    return None


def _attach_doc(line: str, docs: List[str], target) -> bool:
    """Attach any doc body on this line to the given element."""
    match = _RE_DOC_MARKER.search(line)
    if not match or target is None:
        return False
    index = int(match.group(1))
    if 0 <= index < len(docs):
        target.doc = DocBlock(_paragraphs(docs[index]))
    return True


def parse_file(project_root: Path, path: Path, model: Model) -> None:
    """Read one .sysml file into the model, preserving declaration order."""
    text = path.read_text(encoding="utf-8")
    clean, docs = _strip_comments(text)
    relative = path.relative_to(project_root).as_posix()
    model.files.append(relative)

    stack: List[_Frame] = []
    depth = 0
    pending_derive = False

    for line in _logical_lines(clean):
        delta = _brace_delta(line)
        opens = delta > 0
        top = stack[-1] if stack else None

        if line.startswith("#"):
            # A bare annotation such as `#derive` sits above the construct
            # it annotates.
            if "derive" in line:
                pending_derive = True
            depth += delta
            continue

        handled = False

        match = _RE_STORY.search(line)
        if match and _last_segment(match.group(2)) == "UserStory":
            identifier = match.group(1)
            story = Story(
                identifier=identifier,
                source=relative,
                kind=_story_kind(relative, identifier),
                derive_annotation=pending_derive,
            )
            pending_derive = False
            model.stories.append(story)
            _attach_doc(line, docs, story)
            if opens:
                stack.append(_Frame("story", depth + delta, story))
            handled = True

        if not handled:
            match = _RE_CASE.search(line)
            if match:
                identifier = match.group(1)
                case = Case(
                    identifier=identifier,
                    source=relative,
                    kind=_case_kind(relative, identifier),
                )
                model.cases.append(case)
                _attach_doc(line, docs, case)
                if opens:
                    stack.append(_Frame("case", depth + delta, case))
                handled = True

        if not handled:
            match = _RE_CONNECTION.search(line)
            if match and _RE_DERIVATION_TYPE.search(match.group(2)):
                derivation = Derivation(name=match.group(1), source=relative)
                model.derivations.append(derivation)
                if opens:
                    stack.append(_Frame("derivation", depth + delta, derivation))
                handled = True

        if not handled and _nearest(stack, "story") is not None:
            match = _RE_ACCEPTANCE.search(line)
            if match:
                story = _nearest(stack, "story")
                label = (match.group(1) or "").strip("[]") or str(
                    len(story.acceptances) + 1
                )
                acceptance = Acceptance(label=label)
                story.acceptances.append(acceptance)
                _attach_doc(line, docs, acceptance)
                if opens:
                    stack.append(_Frame("acceptance", depth + delta, acceptance))
                handled = True

        if not handled and _nearest(stack, "story") is not None:
            match = _RE_CONSTRAINT.search(line)
            if match:
                story = _nearest(stack, "story")
                constraint = Constraint(name=match.group(1))
                story.constraints.append(constraint)
                _attach_doc(line, docs, constraint)
                if opens:
                    stack.append(_Frame("constraint", depth + delta, constraint))
                handled = True

        if not handled:
            match = _RE_SATISFY.search(line)
            if match:
                model.satisfactions.append(
                    Satisfaction(
                        requirement=_last_segment(match.group(1)),
                        element=_last_segment(match.group(2)),
                        source=relative,
                    )
                )
                handled = True

        if not handled and top is not None and top.kind == "derivation":
            match = _RE_END.search(line)
            if match:
                identifier = _last_segment(match.group(1))
                if not top.data.original:
                    top.data.original = identifier
                elif not top.data.derived:
                    top.data.derived = identifier
                handled = True

        if not handled:
            case = _nearest(stack, "case")
            if case is not None and _RE_VERIFY.search(line):
                for raw_target in _RE_VERIFY.findall(line):
                    target, member = _split_target(raw_target)
                    if target and (target, member) not in case.verifies:
                        case.verifies.append((target, member))
                handled = True

        if not handled and top is not None:
            story = _nearest(stack, "story")
            if story is not None and top.kind == "story":
                match = _RE_NARRATIVE.search(line)
                if match:
                    name = match.group(1)
                    value = " ".join(_unescape(match.group(2)).split())
                    if name == "capability":
                        story.capability = value
                    elif name == "benefit":
                        story.benefit = value
                    handled = True
                if not handled:
                    match = _RE_STAKEHOLDER.search(line)
                    if match:
                        story.role = _last_segment(match.group(2))
                        handled = True
                if not handled:
                    match = _RE_FRAME.search(line)
                    if match:
                        concern = _last_segment(match.group(2))
                        if concern not in story.concerns:
                            story.concerns.append(concern)
                        handled = True

        if not handled and top is not None and top.kind in ("story", "case"):
            match = _RE_SUBJECT.search(line)
            if match:
                top.data.subject = _last_segment(match.group(2))
                handled = True

        if not handled and top is not None:
            _attach_doc(line, docs, top.data)

        depth += delta
        while stack and depth < stack[-1].depth:
            stack.pop()


def find_model_root(project_root: Optional[Path] = None) -> Path:
    """Locate the model tree, mirroring the .iso-config.yaml convention."""
    root = Path(project_root) if project_root else Path.cwd()
    for candidate in MODEL_ROOTS:
        path = root / candidate
        if path.is_dir():
            return path
    raise ModelError(
        "no model directory found at model/ or engineering/model/, "
        "run the renderer from the project root"
    )


def load_model(project_root: Optional[Path] = None) -> Model:
    """Read every .sysml file under the model root, in sorted path order."""
    root = Path(project_root) if project_root else Path.cwd()
    model_root = find_model_root(root)
    model = Model(
        project_root=root, model_root=model_root.relative_to(root).as_posix()
    )
    paths = sorted(
        model_root.rglob("*.sysml"),
        key=lambda path: path.relative_to(root).as_posix(),
    )
    for path in paths:
        parse_file(root, path, model)
    return model


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------


def header(script_name: str) -> str:
    """The fixed first line every generated artefact carries."""
    return (
        f"<!-- Generated by tools/render/{script_name}. "
        "Regenerate, never edit. -->"
    )


def write_document(project_root: Path, relative_path: str, text: str) -> None:
    """Write an artefact with LF endings and a trailing newline."""
    target = project_root / relative_path
    target.parent.mkdir(parents=True, exist_ok=True)
    if not text.endswith("\n"):
        text += "\n"
    with open(target, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def run(render) -> int:
    """Entry point shared by the three renderers.

    The render callable receives the model and returns a
    (relative path, document text) pair. Invocation takes no arguments and
    runs from the project root, which is the contract the post-merge hook
    and the CI freshness check both rely on.
    """
    script_name = Path(sys.argv[0]).name
    try:
        project_root = Path.cwd()
        model = load_model(project_root)
        relative_path, text = render(model)
        write_document(project_root, relative_path, text)
    except ModelError as error:
        sys.stderr.write(f"{script_name}: {error}\n")
        return 1
    except OSError as error:
        sys.stderr.write(f"{script_name}: {error}\n")
        return 1
    print(f"{script_name}: wrote {relative_path}")
    return 0
