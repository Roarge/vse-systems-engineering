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
with `_` is a template and is skipped.

| Option | Effect |
|---|---|
| `--only wellformed` | The §1.9 checks, codes W2, W3, W6, W9 and W10, for the stories in the `.sysml` files named or found. The `precommit_story_wellformed` gate runs this. A `.sysml` file that cannot be read is left to `--only gherkin`. |
| `--only gherkin` | Findings S1 to S9 and F1 to F10 of §11.9.1, for every directory that holds a named file or that a directory search finds. The `precommit_gherkin` gate runs this. |
| `--only syntax` | F1, F2, F7, F8 and F9 for feature files on their own, with no story context. |
| no `--only` | Both `wellformed` and `gherkin`. |
| `--format json` | A JSON array of findings instead of text lines. |

Each text line reads `<path>:<line>: <code> <message> (<section>)`. The
message names the fix. Findings are sorted by path, line and code.

| Exit status | Meaning |
|---|---|
| 0 | No findings |
| 1 | Findings |
| 2 | A usage or environment error, such as a missing path, `tools/render/` missing beside `tools/lint/`, a file system error, or an unexpected error in the lint itself |

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
- **Layout does not matter.** The lint reads each story's narrative
  attributes, role and `@StoryMeta` values from SysML statements, not
  from lines, so a story written on one line is checked the same way.
- **One disposition per finding.** A `.sysml` file that cannot be read,
  or is not UTF-8, is finding S9 under `--only gherkin` alone, so it is
  reported at the `precommit_gherkin` disposition and nowhere else.
