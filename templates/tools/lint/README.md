# Story lint

`story-wellformed.py` checks each user story against its Gherkin feature
file, and checks the story's own form. Gherkin is the plain-text
Given/When/Then format that Cucumber-family test tools read. The lint
implements the story lint of methodology §11.9.1 and the well-formedness
rules of §1.9.

The files in this directory:

| File | Purpose |
|---|---|
| `story-wellformed.py` | The lint |
| `gherkin.py` | The Gherkin parser the lint reads feature files with |

The lint reads the model with `../render/sysml_model.py`, so it needs
`tools/render/` installed beside `tools/lint/`. It uses the Python
standard library only (Python 3.8 or later).

## Running it

Run it from the engineering root, the directory that holds
`.iso-config.yaml`:

```sh
python3 tools/lint/story-wellformed.py model
```

Each argument is a `.sysml` file, a `.feature` file or a directory,
which is searched with its subdirectories. A file whose name starts
with `_` is a template and is skipped. A search reads regular files,
directly or through a link, and dangling links, which it reports as
unreadable. A named pipe, a socket or a device, or a link to one, is
never opened, because reading it could block the lint for ever.

| Option | Effect |
|---|---|
| `--only wellformed` | The §1.9 checks, codes W2, W3, W6, W9 and W10, for the stories in the `.sysml` files named or found. The `precommit_story_wellformed` gate runs this. A `.sysml` file that cannot be read is left to `--only gherkin`. |
| `--only gherkin` | Findings S1 to S9 and F1 to F10 of §11.9.1. Every file of a directory that holds a named file, or that a directory search finds, is read, so each story is paired with its feature file. The story-side findings (S1 to S8) are reported for the stories of those directories. The findings about a file alone (F1 to F10, and S9 for a `.sysml` file) are reported for the files named or found, so naming one file does not report its neighbours. The S codes are reported only in a `stories/` directory. The `precommit_gherkin` gate runs this. |
| `--only syntax` | F1, F2, F7, F8 and F9 for feature files on their own, with no story context. |
| no `--only` | Both `wellformed` and `gherkin`. |
| `--format json` | A JSON array of findings instead of text lines. |
| `--stories ID,ID` | Reports the story-side findings (S1 to S8, and the W codes) for the named stories alone. It may be given more than once, and an empty list names no story. See "Checking some stories" below. |

Each text line reads `<path>:<line>: <code> <message> (<section>)`. The
message names the fix. Findings are sorted by path, line and code.

## Checking some stories

The commit gates check the stories a change touches, not every story
beside them (methodology §11.9). The pre-commit hook works out which
stories those are and passes them with `--stories`, together with the
files the change adds or alters:

```sh
python3 tools/lint/story-wellformed.py --only gherkin \
    --stories US_001_ReadTemperature \
    model/core/stories/stakeholder/stakeholder-stories.sysml
```

- A named story is looked for in every `.sysml` file of the directories
  read, so naming only its feature file is enough to check it.
- The lint still reads the whole model root, so a case anywhere in it
  still reaches a criterion for S8.
- S2 (two feature files for one story) belongs to the story, so it
  follows the story.
- The findings about a file alone are not affected. F1 to F10 apply to
  the feature files named or found, and S9 to the `.sysml` files named
  or found, because a declaration the lint cannot read names no story.

Without `--stories`, every story in the directories read is checked, as
the hook does for a run over every tracked file.

| Exit status | Meaning |
|---|---|
| 0 | No findings |
| 1 | Findings |
| 2 | A usage or environment error, such as a missing path, `tools/render/` missing beside `tools/lint/`, a file system error, a failure to write the findings (a closed pipe or a full disk), or an unexpected error in the lint itself |

An error is reported on one line of standard error, never as a
traceback, so a gate can tell a broken run from a run with findings.

## What it checks

The S and F codes are listed in §11.9.1. The W codes are the §1.9 rules
that the `precommit_story_wellformed` gate keeps:

| Code | Finding |
|---|---|
| W2 | The story does not have exactly one typed `subject`, declared before the role (§1.9 rule 2) |
| W3 | The story has more than one role, or has left `backlog` without a typed role (§1.9 rule 3). The check does not resolve the type to a part definition, because the type may come from an imported library |
| W6 | The `capability` or `benefit` is missing (§1.9 rule 6) |
| W9 | There is no `@StoryMeta { ... }`, or an enumeration value in it is not qualified, as in `status = ready` for `status = StoryStatus::ready` (§1.9 rule 9) |
| W10 | `@StoryMeta` lacks the status, names a status outside the valid list, or lacks a required field once the story has left `backlog` (§1.5, §0.10.3). A story with no status draws only the finding for the status |

These behaviours are worth knowing.

- **What counts as a story.** A story is a requirement usage declared as
  `requirement <ID> : UserStory` or
  `requirement <ID> : VSE_Library::UserStory`. This is the form the
  plugin's in-session Gherkin-first hook reads. Any other declaration
  that types or specialises `UserStory` is finding S9, so a story the
  hook cannot read is never passed unchecked.
- **Stories live in a `stories/` directory.** §11.2.1 pairs each story
  with its feature file in a stories directory, so the S findings are
  reported only there. A story declared in another directory, such as
  `model/core/requirements/`, is not checked, and a feature file beside
  it draws F10, whose advice is to move the story into a stories
  directory with its feature file.
- **Where coverage comes from.** Finding S8 needs to know which
  verification and validation cases reach each criterion, and which
  `satisfy` relationships name each story. The lint reads both from the
  whole model root (`model/` or `engineering/model/` under the current
  directory) as well as from the files named, so naming one stories
  directory is enough.
- **The `storymeta` configuration.** `storymeta.required_fields` and
  `storymeta.valid_statuses` in `.iso-config.yaml` are read when
  present. A required field is required once the story leaves
  `backlog`. Without the block, only the status is required and the
  four statuses of §1.5 are valid. The status itself is always
  required, because §1.5 makes it mandatory and the other checks depend
  on it.
- **A status the lint cannot place.** A story whose status cannot be
  read, or whose status the §11.4 ordering table does not rank (such as
  one a project adds to `valid_statuses`), is held to the strictest row
  of that table, `inProgress` and `done`, and the S8 finding says why.
  W3 also counts any status other than `backlog` as past backlog, so a
  story is never left unchecked.
- **Layout does not matter for stories and cases.** The lint reads each
  story's narrative attributes, role and `@StoryMeta` values from SysML
  statements, not from lines, so a story written on one line is checked
  the same way. A verification or validation case written on one line
  with its objective, or several cases on one line, reach their
  criteria as they would over several lines.
- **One disposition per finding.** A `.sysml` file that cannot be read,
  or is not UTF-8, is finding S9 under `--only gherkin` alone, so it is
  reported at the `precommit_gherkin` disposition and nowhere else.
- **Each finding once.** A file that two searched directories reach,
  one of them through a link, is checked in both, and each finding
  about it is reported once.
