# ISO/IEC 29110 Compliance Hooks Guide

*A companion to the methodology specification — implementation
guidance for automating ISO/IEC TR 29110‑5‑6‑2:2014 compliance with
git hooks and Claude Code hooks.*

## 1. Purpose

This guide specifies how to automate the ISO/IEC 29110 compliance
discipline established in §9 (compliance mapping) and §10 (Project
Management) of the methodology. The goal is to make compliance
*ambient* rather than periodic — the right things happen because the
tools do them, not because someone remembered.

Two hook surfaces are exploited:

1. **Git hooks** — fire on git events (commit, push, merge, etc.) and
   either gate the operation (block on violation) or trigger
   side-effects (regenerate derived artefacts, notify a backup remote).
2. **Claude Code hooks** fire on agent events (session start, prompt
   submission, tool use, response completion). They either inject
   context (compliance status, ISO obligations relevant to the task)
   or gate agent actions. The `PreToolUse` hook denies an agent's edit
   that adds or changes a story without its Gherkin feature file, or
   that changes code without a test, per methodology §11.

The two surfaces complement each other. Git hooks, with the CI that
reruns them, are the *enforcement* layer. They prevent non-compliant
state from reaching the repository. Claude Code hooks are mostly the
*guidance* layer. They keep the agent and its operator aligned with ISO
obligations during authoring. The exception is `PreToolUse`, which
carries the two in-session gates of methodology §11.9 and stops an
agent before the edit rather than at the commit.

## 2. ISO/IEC 29110 obligations covered by hooks

| ISO obligation | Hook(s) that cover it |
|---|---|
| PM.O1: Plan reviewed and accepted | Plan-revision PR review and the `plan-baseline-*` tag, plus PR-required CI lint |
| PM.O2: Progress monitored, corrections taken | `post-merge` regenerator, and the CC `Stop` reminder for a Progress Status entry |
| PM.O3: Change Requests handled | `pre-commit` baselined-artefact check, and the CC `PreToolUse` reminder on an edit to a baselined path |
| PM.O4: Review meetings recorded | `commit-msg` meeting commit format, and the CC `UserPromptSubmit` reminder after a synchronous review |
| PM.O5: Risk register monitored | CC `SessionStart` risk summary, and a weekly CI job for stale risks |
| PM.O6: Configuration management | CI baseline integrity on tags (§4.4 contract 4), and mirroring via `post-receive` |
| PM.O7: V&V performed | CI verification coverage per acceptance criterion (§4.4 contract 2), and CI runs of `test_command` and `scenario_command` where `test_first` records them |
| PM.O8: Disposal Management Approach | CI lint for Plan completeness |
| SR.O2: Requirements analysed and baselined | `pre-commit` story well-formedness and Gherkin conformance (`precommit_gherkin`), and the CC `PreToolUse` Gherkin-first gate (`pretooluse_gherkin_first`) |
| SR.O3: Architectural design baselined, with traceability | `pre-commit` traceability check on touched requirements, the CI traceability integrity check (§4.4 contract 3, which rejects dangling `derive`, `frame concern` and `verify` references), and `post-merge` Traceability Matrix regeneration |
| SR.O4: System elements produced with acceptance tests | `pre-commit` test-first gate (`precommit_test_first`), the CC `PreToolUse` test-first gate (`pretooluse_test_first`), and the CI `test_command` run (methodology §11) |
| SR.O6: System Configuration baselined | Tag protection, and the CI baseline check on tags (§4.4 contract 4) |
| SR.O7: V&V tasks performed, reports stored | `post-merge` V&V report aggregator, and the CC `Stop` reminder after V&V execution |

Coverage is not exhaustive — hooks reduce friction but do not replace
human judgement. The hooks raise the floor; the team raises the
ceiling.

That principle is now normative, and it lives in §0.10 of the
methodology. §0.10.1 states the floor-and-ceiling posture, §0.10.2
defines the three project profiles, §0.10.4 fixes the disposition of
each configurable gate per profile together with the per-gate override
convention, and §0.10.6 gives the bypass-with-rationale rule its single
home. This guide implements that section. Where the two disagree, §0.10
is right and this guide is wrong. The coverage table above describes the
`full` profile, which is the only profile that installs the complete set.

## 3. Repository setup

### 3.1 Hook directory structure

```
<repo-root>/
├── .git/                         # standard git directory
├── .githooks/                    # checked-in hook scripts
│   ├── pre-commit
│   ├── commit-msg
│   ├── prepare-commit-msg
│   ├── post-merge
│   ├── post-checkout
│   └── lib/                      # shared helpers
│       ├── iso-checks.sh
│       └── story-lint.py
├── .claude/                      # Claude Code configuration
│   ├── settings.json             # hook configuration
│   └── hooks/                    # Claude Code hook scripts
│       ├── session-start.sh
│       ├── pre-tool-use.sh
│       ├── post-tool-use.sh
│       ├── stop.sh
│       └── lib/
│           └── iso-status.sh     # shared with .githooks/lib
├── tools/                        # methodology tooling
│   ├── render/                   # model → ISO documents
│   │   ├── traceability-matrix.py
│   │   ├── stakeholder-reqs-doc.py
│   │   └── system-reqs-doc.py
│   └── lint/
│       ├── story-wellformed.py
│       └── plan-complete.py
├── .github/workflows/            # CI for things hooks alone can't do
│   └── compliance.yml
└── docs/                         # ISO/IEC 29110 artefacts
    ├── project-plan.md
    ├── progress-status-record.md
    ├── correction-register.md
    ├── risk-register.md
    ├── product-acceptance-record.md
    ├── meetings/
    ├── decisions/
    └── templates/
```

### 3.2 Activate the hooks

Git hooks live in `.git/hooks/` by default but that directory is not
versioned. The standard workaround is to use `core.hooksPath`:

```bash
# Run once per clone:
git config core.hooksPath .githooks
chmod +x .githooks/*
```

Optionally, automate this in `tools/setup.sh` and document it in the
README under "First-time setup."

For Claude Code, settings live in `.claude/settings.json` (project-
local) or `~/.claude/settings.json` (user-level). Project-local
settings take precedence and are version-controlled.

### 3.3 Verify the documentation cutoff

Claude Code hook APIs evolve. Before deploying the configurations in
this guide, verify the current hook event names and JSON schemas
against the official documentation at
`https://docs.claude.com/en/docs/agents-and-tools/claude-code/hooks`.
Any changes since this guide was written should be applied to the
example configurations below.

### 3.4 Profile-based installation

Which hooks are installed is a function of the project's rigour profile
(methodology §0.10.2). Installing the whole set into a solo prototype
produces gates nobody wants and teaches the engineer to reach for a
bypass on the first day, which is the opposite of the intended effect.

| Surface | light | standard | full |
|---|---|---|---|
| `.githooks/prepare-commit-msg` | installed | installed | installed |
| `.githooks/post-checkout` | installed | installed | installed |
| `.githooks/lib/` (shared helpers, including `test-first.sh`) | installed | installed | installed |
| `.githooks/pre-commit` and its traceability delegate | installed: Gherkin and test-first gates block, SysML lint warns, traceability prints one line | installed: Gherkin and test-first gates block, the others warn | installed, blocking dispositions |
| `.githooks/commit-msg` | not installed | installed, warn dispositions | installed, blocking dispositions |
| `.githooks/post-merge` | not installed | not installed | installed |
| `tools/lint/` (story lint and Gherkin parser) | installed | installed | installed |
| `.github/workflows/` compliance workflows | `traceability-check.yml`: gates per configuration, test and scenario steps where test first applies, model validation and Contract 3 advisory | `traceability-check.yml`: gates per configuration, test and scenario steps where test first applies, model validation and Contract 3 advisory | `traceability-check.yml` blocking, plus `document-export.yml` (renders documents on release, never blocks) |
| Branch protection on `main` | not configured | recommended | required |

Four notes on the table.

`prepare-commit-msg` and `post-checkout` do not gate anything. They
prepopulate a commit message from the branch name and report state after
a checkout, so they cost nothing at any rigour level.

`.githooks/lib/` installs at every profile even where no installed hook
reads it yet. Raising a profile later then adds hook files only, with no
second install step and no partial state.

`pre-commit`, `tools/lint/` and the CI workflow install at every profile,
because they carry the Gherkin-first and test-first gates of methodology
§11.9, which block at every profile. A side effect at `light` is that the
SysML lint (`precommit_lint`, warn) and the traceability check
(`precommit_traceability`, info) run there too. The workflow's pre-commit
step reads every gate's disposition from `.iso-config.yaml`, so it needs
no advisory toggle. The `commit-msg` hook stays off at `light`. An
existing project receives new versions of the git hooks by re-running
the install, and the project audit flags drift between the installed
copies and the plugin's.

The dispositions in every column are defaults, not fixtures. A project
sets any individual gate to `block`, `warn`, `info` or `off` through
`gate_overrides` in `.iso-config.yaml`, per methodology §0.10.4. That is
the mechanism to reach for when one gate is wrong for a project, rather
than declining to install the hook that carries it. Lowering one of the
four gates of methodology §11 also records its reason on the tailoring
line, and an agent never does it unasked (methodology §11.10).

This subsection operationalises the phased-rollout advice in §12. A
project adopting the methodology on an existing repository starts at
`light`, raises to `standard` once the model parses cleanly and the
commit conventions are habitual, and raises to `full` when an acquirer
or an assessment makes the complete artefact set worth its cost. Each
step is a one-line change to `project_profile` followed by a re-run of
the install.

## 4. Git hooks

### 4.1 `pre-commit`

**Purpose.** Block commits that introduce non-compliant state.

**Checks performed:**

1. **SysML model lint.** Run a SysML v2 parser against every changed
   `.sysml` file; fail on syntax error.
2. **Story well-formedness.** For the stories the change touches in
   `model/core/stories/` or
   `model/core/logical-architecture/components/.../stories/` (see
   "Touched stories" below), run the story linter with
   `--only wellformed` and `--stories` naming them (methodology §1.9
   rules 2, 3, 6 and 9, plus the `storymeta` fields).
3. **Baselined-artefact protection.** If a file under a baselined
   path (configured in `.iso-config.yaml`) has been changed, require
   the commit message to reference an open Change Request issue.
4. **Traceability integrity.** Reject commits that introduce dangling
   `derive`, `frame concern`, or `verify` references.
5. **Gherkin conformance.** For the stories the change touches, and
   the story files and `.feature` files it changes, run the story
   linter with `--only gherkin` and `--stories` naming those stories
   (methodology §11.9, findings S1 to S9 and F1 to F10). A changed
   `.feature` file under `model/` that sits outside a `stories/`
   directory is linted as well, so F10 reports it. A `.feature` file
   outside `model/`, such as a Cucumber feature for the project's
   code, is the project's own and is left alone.
6. **Test before code.** Where `test_first.applies` is `true`, reject a
   change to a code path that arrives with no change to a test path,
   either in the commit set or on the branch since its merge base
   (methodology §11.9). A test left untracked or unstaged is in
   neither. In range mode the range is the commit set. The branch
   since its merge base also counts when a branch is checked out, as
   CI does for a push, so a push that brings the code counts the test
   an earlier push brought. CI checks a pull request out detached, so
   there the range alone counts, and it already runs from the merge
   base. On a branch that matches `refactor_branches` the finding is a
   reminder. Where `test_first.applies` is unrecorded, report when
   test tooling is detected or a changed path matches a `code_paths`
   or `test_paths` glob already recorded, and otherwise print one line
   suggesting `/vse-test-first`.

**File set.** By default the hook checks the staged set.
`VSE_PRECOMMIT_RANGE` switches it to range mode: a git range such as
`origin/main...HEAD` checks the files that range changes, and the value
`all` checks every tracked file. CI uses range mode (§4.4), because a
fresh CI checkout has nothing staged and a staged-set check would pass
vacuously.

**Touched stories.** Checks 2 and 5 read the stories a change touches
(methodology §11.9.2). A story is touched when the change adds its
declaration block or alters the block's text, or adds, changes, renames
or deletes its `<StoryIdentifier>.feature` file. The hook compares the
blocks with the scanner of `lib/test-first.sh`, the one the
`PreToolUse` Gherkin-first gate uses, so "touched" means the same at
commit time and in session. The comparison runs between `HEAD` and the
staged set, or between the start and the end of the range, where the
start of `<base>...<head>` is the merge base. A story file the change
renames, as git detects renames, within its stories directory or with
the whole directory, is compared with the story file it was renamed
from, so renaming a register or a stories directory touches none of
its stories. The old directory counts as moved whole when, after the
change, it holds no story or feature file other than a template (a
file whose name begins with `_`). A story file moved on its own to
another directory leaves its feature files behind, so its stories
count as touched, and the stories of a template renamed to a working
name count as new. Deleting a story touches nothing. When the change
deletes a feature file, the hook passes the story files of that
directory that declare its story, so that S1 is reported, and an S9
elsewhere in such a file is reported with it. Stories in the same
stories directories that the change leaves alone, and that would draw
S1, S3 or S9, are named in one note that points at `/vse-audit`, and
they never block a staged or range commit. With `all` every story is
checked, so the run CI makes at a release tag needs every story
migrated. Without `lib/test-first.sh` (a partial install) the hook
cannot tell which stories are touched, so it checks every story in each
stories directory the change touches.

**Disposition per profile.** "Block" above describes the `full` profile.
Checks 1, 2, and 4 carry the configuration keys `precommit_lint`,
`precommit_story_wellformed`, and `precommit_traceability`, whose
disposition per profile and override mechanism are fixed by methodology
§0.10.4. Checks 5 and 6 carry `precommit_gherkin` and
`precommit_test_first`, which block at every profile unless a recorded
override lowers them. A missing story linter or a missing `python3` is
reported at the gate's own disposition, so a broken install cannot pass
quietly. Check 3 is governed by the `commit_msg_cr_reference` gate in
§4.2, because the Change Request reference it looks for lives in the
commit message. Where the disposition is `warn` the check prints the
same finding and the commit proceeds. Where it is `off` the check does
not run.

**Sample script (`.githooks/pre-commit`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/iso-checks.sh"

# 1. SysML lint
changed_sysml=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sysml$' || true)
if [[ -n "$changed_sysml" ]]; then
    iso::lint_sysml $changed_sysml || {
        echo "❌ SysML lint failed. Fix syntax errors before committing." >&2
        exit 1
    }
fi

# 2. Story well-formedness. The shipped hook narrows this check and
#    check 5 to the stories the change touches, named with --stories,
#    and passes the changed story and feature files (methodology
#    §11.9.2, "Touched stories" above). This sketch leaves --stories
#    out, so it checks every story it reads.
changed_stories=$(echo "$changed_sysml" | grep -E '/(stories|requirements)/' || true)
if [[ -n "$changed_stories" ]]; then
    python3 tools/lint/story-wellformed.py --only wellformed $changed_stories || {
        echo "❌ Story well-formedness failed (§1.9)." >&2
        exit 1
    }
fi

# 3. Baselined-artefact protection
if iso::touches_baselined; then
    if ! iso::commit_references_change_request; then
        echo "❌ Edit to baselined artefact without referenced Change Request." >&2
        echo "   Open an issue with label 'change-request' and reference it as" >&2
        echo "   'CR #<n>' in the commit message." >&2
        exit 1
    fi
fi

# 4. Derived-artefact freshness (Contract 3)
python3 tools/render/traceability-matrix.py || {
    echo "❌ Traceability matrix could not be regenerated." >&2
    exit 1
}
git add --intent-to-add -- docs/generated/
git diff --exit-code --quiet -- docs/generated/ || {
    echo "❌ docs/generated/ is stale. Stage the regenerated artefacts (hooks guide Contract 3)." >&2
    exit 1
}

# 5. Gherkin conformance (methodology §11.9). The shipped hook narrows
#    it to the touched stories, as for check 2.
story_dirs=$(git diff --cached --name-only --diff-filter=ACMRD |
    grep -E '/stories/.*\.(sysml|feature)$' | sed 's|/[^/]*$||' | sort -u || true)
if [[ -n "$story_dirs" ]]; then
    python3 tools/lint/story-wellformed.py --only gherkin $story_dirs || {
        echo "❌ Gherkin conformance failed (methodology §11.9)." >&2
        exit 1
    }
fi

# 6. Test before code (methodology §11.9). The shipped hook classifies
#    each path against test_first.code_paths and test_paths with
#    .githooks/lib/test-first.sh.
if iso::test_first_applies && iso::code_changed_without_test; then
    echo "❌ Code changed with no test change. Write the failing test first (methodology §11.7)." >&2
    exit 1
fi

echo "✅ pre-commit ISO/IEC 29110 checks passed."
```

### 4.2 `commit-msg`

**Purpose.** Enforce commit-message conventions that make audit trails
queryable.

**Checks performed:**

1. **Story-scoped commits** must reference a Story ID
   (`feat(US_042): ...` or `fix(SYS_142): ...`).
2. **Plan/CR commits** must reference an Issue number
   (`plan: ... (CR #17)` or `feat: ... (CR #23)`).
3. **Conventional types** are enforced: `feat`, `fix`, `docs`,
   `refactor`, `test`, `chore`, `plan`, `meeting`.

**Disposition per profile.** Checks 1 and 3 are the single
`commit_msg_pattern` gate. Check 2, together with the Change Request
reference required for any staged path on `baselined_paths`, is the
`commit_msg_cr_reference` gate. Both dispositions per profile and the
override mechanism are fixed by methodology §0.10.4. The sample script
below shows the `full` behaviour, which exits non-zero. At `standard`
the same finding prints with a warning prefix and the hook exits zero.
At `light` neither gate runs.

A blocking message names the rule and points at methodology §0.10.6. It
does not name a bypass flag, for the reason given in that section.

**Sample script (`.githooks/commit-msg`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
msg_file=$1
msg=$(head -n1 "$msg_file")

# Allowed forms:
#   <type>(<scope>): <subject>      [scope is Story ID or omitted]
#   <type>: <subject> (CR #<n>)     [Plan/Change Request work]
#   meeting: <date> <topic>          [Meeting Record commit]
pattern_story='^(feat|fix|docs|refactor|test|chore)(\(([A-Z]+_[0-9]+_[A-Za-z0-9]+|US_[0-9]+|SYS_[0-9]+|[A-Z]+_[0-9]+)\))?: .+'
pattern_cr='^(plan|feat|fix|docs|refactor|chore): .+ \(CR #[0-9]+\)$'
pattern_meeting='^meeting: [0-9]{4}-[0-9]{2}-[0-9]{2} .+'

if [[ "$msg" =~ $pattern_story || "$msg" =~ $pattern_cr || "$msg" =~ $pattern_meeting ]]; then
    exit 0
fi

cat >&2 <<EOF
❌ Commit message does not match required conventions.

Allowed forms:
  feat(US_042): brief subject
  fix(SYS_142): brief subject
  plan: revise schedule (CR #17)
  meeting: 2026-05-05 architecture sync

Got: "$msg"
EOF
exit 1
```

### 4.3 `prepare-commit-msg`

**Purpose.** Reduce friction by prepopulating commit messages with
the Story ID inferred from the branch name.

**Sample script (`.githooks/prepare-commit-msg`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
msg_file=$1
source_type=${2:-}

# Skip if the message is already set (merge, squash, etc.)
[[ -n "$source_type" ]] && exit 0

branch=$(git branch --show-current)
# story/US_042_AckFromDashboard → US_042
if [[ "$branch" =~ ^story/([A-Z]+_[0-9]+) ]]; then
    story_id=${BASH_REMATCH[1]}
    # Only prepopulate if the file currently begins with a comment line
    if head -n1 "$msg_file" | grep -q '^#'; then
        sed -i "1i feat($story_id): " "$msg_file"
    fi
fi
```

### 4.4 Pre-push obligations as CI contracts

**No local `pre-push` hook ships.** The four obligations below are
continuous-integration contracts, not workstation checks. Two reasons.
They are expensive, and a check that adds seconds to every push is a
check the engineer learns to skip. And they are exactly the class of
obligation that must not be bypassable from a workstation, which a local
hook can never guarantee and a required status check on a protected
branch can (see this guide's §11 and methodology §0.10.6).

The four contracts remain part of the methodology. A `full`-profile
project implements them in CI, gated as required status checks on `main`
and on release tags. A `standard` project implements as many as it finds
useful, advisory. Contract 2 ships at every profile, as finding S8
of the `precommit_gherkin` gate, which runs in the `pre-commit` hook and
in CI (methodology §11.9). The contracts are stated here so a CI
implementer has the specification without reading the deleted script.

**Contract 1: story state on protected references.** No commit reaching
`main` carries a story whose `StoryMeta.status` is `inProgress`. Story
status is read from the `StoryMeta` metadata of each story file in the
pushed tree. This is the check methodology §8.7 names.

**Contract 2: verification coverage.** Every acceptance criterion of
every story at `status = inProgress` or `status = done` in the pushed
tree is reached by at least one verification or validation case,
through `verify <story>`, `verify <story>.acceptance` or
`verify <story>.acceptance.<name>` (methodology §11.3.3, §11.4). This is
the SR.O7 obligation of §9.4, checked per criterion rather than per
story. The story lint reports a violation as finding S8.

**Contract 3: traceability matrix freshness.** The Traceability Matrix
regenerated from the pushed tree matches the committed copy at
`docs/generated/traceability-matrix.md`. A mismatch means the committed
matrix is stale, per §9.8.

**Contract 4: baseline integrity on tags.** When an annotated tag
matching the project's baseline pattern is pushed, every artefact under
configuration management in the tagged tree is in `baselined` state,
per §10.8 of the methodology.

The plugin ships `templates/github/traceability-check.yml`, installed at
every profile per §3.4. It implements contract 3 directly. It implements
contract 2 through the story lint, because its pre-commit step runs the
`pre-commit` hook, and the `precommit_gherkin` gate reports S8 there at
its configured disposition: for the stories a pull request or a push
touches in range mode, and for every story at a release tag, where the
hook reads every tracked file. It also runs
`test_command` and `scenario_command` where test first applies, that
is when `test_first.applies` is `true` and the command is recorded
(methodology §11.8). A record where `test_first.applies` is `true`
without `test_command` is invalid (methodology §11.5.2), so the
workflow fails on it rather than pass with no test run. Range mode
needs the full history, so the workflow
checks out with `fetch-depth: 0` and sets `VSE_PRECOMMIT_RANGE` per
event: the pull request's base and head for a pull request, the
previous and new commits for a push, and every tracked file (`all`) for
a tag or for a push with no previous commit. Contracts 1 and 4 are
documented specifications that the project implements against its own
CI platform, because each depends on the project's tag pattern,
renderer choice, and configuration-management scope.

### 4.5 `post-merge`

**Purpose.** Regenerate model-derived artefacts when `main` advances.

**Side-effects performed:**

1. **Traceability Matrix** regenerated to
   `docs/generated/traceability-matrix.md`.
2. **Stakeholder and System Requirements Specifications** rendered to
   `docs/generated/stakeholder-requirements.md` and
   `docs/generated/system-requirements.md`.
3. **Progress Status Record** entry stub appended when the merge
   closes a story or lands a release baseline.

**Sample script (`.githooks/post-merge`):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Only run on main
[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || exit 0
cd "$(git rev-parse --show-toplevel)"

# The directory that holds .iso-config.yaml is the engineering root: the
# project root in a greenfield layout, engineering/ in a brownfield one.
if [ -f .iso-config.yaml ]; then
    ENG_ROOT="."
elif [ -f engineering/.iso-config.yaml ]; then
    ENG_ROOT="engineering"
else
    exit 0
fi

# Run every renderer named under renderers: from the engineering root.
# Each one writes its own destination under docs/generated/.
echo "Regenerating ISO/IEC 29110 derived artefacts..."
(
    cd "$ENG_ROOT"
    python3 tools/render/traceability-matrix.py   # docs/generated/traceability-matrix.md
    python3 tools/render/stakeholder-reqs-doc.py  # docs/generated/stakeholder-requirements.md
    python3 tools/render/system-reqs-doc.py       # docs/generated/system-requirements.md
)

if git diff --quiet -- "$ENG_ROOT/docs/"; then
    echo "Derived artefacts already current."
else
    echo "Derived artefacts regenerated. Commit the updates or run CI."
fi
```

(Note: `post-merge` cannot itself create commits without surprising
the user; it regenerates and *reports* drift. Production of the
follow-up commit is left to CI on `main` — see §6.)

### 4.6 `post-checkout`

**Purpose.** Inform the operator of compliance status when switching
branches.

**Sample script (`.githooks/post-checkout`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
prev=$1; new=$2; checkout_type=$3
[[ "$checkout_type" == "1" ]] || exit 0   # only on branch checkouts

bash .claude/hooks/lib/iso-status.sh
```

The shared `iso-status.sh` is reused by Claude Code's
`SessionStart` hook (§5.1) so the operator and the agent see the
same status.

### 4.7 `post-receive` (server-side)

**Purpose.** Mirror to backup remote (CM Strategy backup
requirement, §10.8).

**Sample script (deployed on the canonical remote):**

```bash
#!/usr/bin/env bash
set -euo pipefail
git push --mirror git@backup-remote:org/project.git
```

This belongs on the server hosting the canonical remote (GitHub or
self-hosted GitLab). For SaaS hosts, equivalent functionality is
provided via mirroring features in the host's admin UI.

## 5. Claude Code hooks

Claude Code hooks are configured in `.claude/settings.json`. The full
schema is at `https://docs.claude.com/en/docs/agents-and-tools/claude-code/hooks` —
verify the field names below against current docs.

**Output contract.** What a hook prints reaches Claude only in the form
its event expects.

- For `SessionStart` and `UserPromptSubmit`, plain text on stdout is
  added to Claude's context.
- For `PreToolUse`, `PostToolUse`, `Stop` and `SubagentStop`, Claude
  never sees plain stdout. A hook with something to say prints exactly
  one JSON object on stdout. A hook with nothing to say prints nothing.
- Diagnostics go to stderr, never to stdout, so they cannot corrupt
  the JSON object.

The JSON fields this guide uses are `hookSpecificOutput.hookEventName`
(the event name, always present), `hookSpecificOutput.permissionDecision`
(`deny` or `ask`, `PreToolUse` only) with
`hookSpecificOutput.permissionDecisionReason`,
`hookSpecificOutput.additionalContext` (text added to the agent's
context), and the top-level `systemMessage` (text shown to the human).

### 5.1 `SessionStart`

**Purpose.** Inject project compliance state at the start of every
session, so Claude has up-to-date context on what's baselined, what's
in flight, and what's overdue.

**Configuration (excerpt from `.claude/settings.json`):**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/session-start.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
cat <<EOF
=== ISO/IEC 29110 Project Status ===

Branch:           $(git branch --show-current)
Project Plan:     $(git tag -l 'plan-baseline-*' | tail -1 || echo "not yet baselined")

In-flight stories ($(python3 tools/lint/count-stories.py --status inProgress)):
$(python3 tools/lint/list-stories.py --status inProgress | head -10)

Pending Change Requests ($(gh issue list -l change-request -s open --json number | jq length 2>/dev/null || echo "?")):
$(gh issue list -l change-request -s open --json number,title --jq '.[] | "  CR #\(.number): \(.title)"' 2>/dev/null | head -5)

Stale risks (>30 days since review):
$(python3 tools/lint/stale-risks.py 2>/dev/null | head -5)

Reminders:
- Edits to baselined artefacts require an open Change Request (PM.O3).
- New stories shall declare role, capability, benefit, ≥1 acceptance (§1.9).
- Behaviour first: write <ID>.feature before the story it describes (§11.4).
- Test first: if a test-driven development skill is listed in your
  skills, use it, otherwise follow methodology §11.7.
- After modifying a story, update its verification case (SR.O7).
- Stories build forward from the Base Architecture (§2.1). Do NOT
  reverse-engineer or auto-generate stakeholders, concerns, or
  stories that explain Base Architecture decisions; create context
  stories only on explicit user request, with confirmation of intent
  (§2.6 rule 7).

EOF
```

The output is injected into Claude's context at session start. Claude
then has the same situational awareness as a human operator running
`git status` plus their tracking tools.

### 5.2 `UserPromptSubmit`

**Purpose.** Detect prompts that imply ISO-relevant actions and
inject reminders before the agent plans its work.

**Triggers:**

- Prompts containing keywords for *change* applied to plausibly
  baselined artefacts.
- Prompts that reference synchronous review/meeting events
  (suggest creating a Meeting Record).
- Prompts that imply new story authoring (suggest the §1 template).

**Configuration:**

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/user-prompt-submit.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/user-prompt-submit.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
# The user prompt arrives on stdin as JSON (per Claude Code hook contract).
prompt=$(jq -r '.prompt // .user_message // ""')

# Heuristic: edits + plausibly baselined artefact references
if echo "$prompt" | grep -qiE '(change|edit|modify|update|delete).*(plan|baselined|US_[0-9]+|SYS_[0-9]+|architecture)'; then
    cat <<EOF
[ISO/IEC 29110 reminder]
This prompt may involve changes to baselined or load-bearing artefacts.
Per PM.O3 (Change Request handling) and §10.4.2:
- Confirm with the user whether a Change Request issue exists.
- If not, propose opening one with cost/schedule/technical impact analysis.
- Reference 'CR #<n>' in any commit modifying baselined artefacts.
EOF
fi

# Heuristic: meeting/review mentions
if echo "$prompt" | grep -qiE '(meeting|reviewed with|sync|standup) (today|yesterday|this morning)'; then
    cat <<EOF
[ISO/IEC 29110 reminder]
A synchronous review may have occurred. Per PM.O4:
- Capture a Meeting Record in docs/meetings/<YYYY-MM-DD>-<topic>.md.
- Include attendees, agreements, open issues, next meeting.
EOF
fi

# Heuristic: requests that imply reverse-engineering of pre-existing
# context. The methodology forbids agents from synthesising stories,
# stakeholders, or concerns that "explain" Base Architecture decisions
# (§2.1 corollary 2; §2.6 rule 7).
if echo "$prompt" | grep -qiE '(generate|create|infer|complete|fill in|fill out|reverse[- ]?engineer|derive).*(stories|stakeholders|concerns|requirements).*(for|from|based on|covering|matching).*(platform|architecture|existing|current|legacy|base|infrastructure)'; then
    cat <<EOF
[ISO/IEC 29110 reminder — agent-collaboration discipline]
This prompt may be asking for stories, stakeholders, or concerns to be
synthesised from pre-existing context (Base Architecture, legacy
system, existing infrastructure). Per §2.1 corollary 2 and §2.6 rule
7, the agent shall NOT auto-generate context stories or
reverse-engineer Base Architecture justifications.

If the user explicitly wants context stories for organisational memory
or audit trail, confirm intent first ("you want me to author X
deliberately as context — confirm?") and clearly mark the resulting
artefacts as context, not as forward-going required output.

If the user wants forward-going work, ignore the existing context as
specification material and focus on what the project shall *add*.
EOF
fi
```

The script's stdout is appended to the prompt context (per Claude
Code hook semantics) — Claude sees the reminder and can act on it
before responding.

### 5.3 `PreToolUse`

**Purpose.** Carry the two in-session gates of methodology §11.9 before
an agent's file edit lands, and remind the agent of the obligations an
edit touches.

- **Gherkin first** (`pretooluse_gherkin_first`). An edit that adds a
  story, or changes a story's text, is denied while the story's
  `<ID>.feature` is missing or lacks the `@<ID>` tag. A story's text is
  its declaration and its body, from the declaration line through its
  matching closing brace.
- **Test first** (`pretooluse_test_first`). Where `test_first.applies`
  is `true`, an edit to a code path is denied while no test path has
  changed in the working tree or on the branch.
- **Configuration edits.** An edit that changes `gate_overrides` or
  `test_first` in `.iso-config.yaml` asks the human to confirm it
  (methodology §11.10).
- **Reminders.** An edit to a baselined path draws a Change Request
  reminder (PM.O3), and an edit to a story file draws the §1.9
  reminder. The Change Request gate itself is `commit_msg_cr_reference`
  at commit time (methodology §0.10.4).

Each gate's disposition comes from `.iso-config.yaml`, as for the git
hooks. Methodology §11.9.3 specifies what each gate checks, and §11.11
states what it cannot see.

**Configuration (with matchers for the file tools):**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/pre-tool-use.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
payload=$(cat)
target=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
[[ -z "$target" ]] && exit 0

# Exactly one JSON object on stdout per call, and never an explicit allow.
emit() {   # emit <decision|""> <text>
    if [[ -n "$1" ]]; then
        jq -n --arg d "$1" --arg r "$2" '{hookSpecificOutput: {hookEventName: "PreToolUse",
            permissionDecision: $d, permissionDecisionReason: $r}}'
    else
        jq -n --arg c "$2" '{hookSpecificOutput: {hookEventName: "PreToolUse",
            additionalContext: $c}}'
    fi
    exit 0
}

case "$target" in
    */.iso-config.yaml)
        # The shipped hook asks only when gate_overrides or test_first change.
        emit ask "This edit changes gate_overrides or test_first. Confirm that a human asked for it (methodology §11.10)."
        ;;
    */stories/*.sysml)
        # Templates and the model library are never Gherkin-gated.
        # Templates sit in subdirectories such as
        # stories/stakeholder/_template.sysml, so match the file name alone.
        case "$(basename "$target")" in _*) exit 0;; esac
        case "$target" in */model/library/*) exit 0;; esac
        # touched_story_ids applies the edit to the file first, then lists
        # the stories it adds or changes. Untouched siblings are not gated.
        for id in $(touched_story_ids "$payload" "$target"); do
            feature="$(dirname "$target")/$id.feature"
            feature_has_tag "$feature" "$id" ||
                emit deny "Story $id has no feature file. Write $feature with the tag @$id and the story narrative first (methodology §11.2)."
        done
        emit "" "Story file edit. Mirror every @AC_ tag as a named criterion inside requirement :>> acceptance (methodology §11.3, §1.9)."
        ;;
esac

# Test first, when test_first.applies is true (methodology §11.9).
if test_first_applies && is_code_path "$target" && ! has_test_evidence; then
    emit deny "No test change found for $target. Write the failing test first (methodology §11.7)."
fi

# Baselined artefacts: a reminder, not a denial.
if is_baselined "$target"; then
    emit "" "$target is a baselined artefact. Per PM.O3 the change needs an open Change Request, referenced as 'CR #<n>' in the commit."
fi
exit 0
```

`touched_story_ids`, `feature_has_tag`, `test_first_applies`,
`is_code_path`, `has_test_evidence` and `is_baselined` stand for the
helpers of the shipped hook, which live in its `lib/test-first.sh` and
`lib/iso-profile.sh`. The shipped hook also combines every finding for
one call into a single object, with a denial taking precedence over a
request to ask, and a request to ask over added context.

**What Claude Code receives.** A denial looks like this:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Story US_007_ExportReadings has no feature file. Write model/core/stories/stakeholder/US_007_ExportReadings.feature with the tag @US_007_ExportReadings and the story narrative first (methodology §11.2)."
  }
}
```

Claude Code refuses the tool call and shows the reason to the agent,
which then writes the feature file and retries. The reason names the
expected file, the rule and the methodology section, and stays under
1,500 characters. A `warn` disposition sends the finding as
`additionalContext` instead, and the call proceeds. The edit has then
happened, so a warning never asks the agent to retry it. It asks for
the feature file or the failing test next. An `info` disposition adds
one line of context, and `off` skips the gate. An `ask` decision puts
the call to the human for confirmation.

The hook never prints `"permissionDecision": "allow"`. An explicit allow
would skip the engineer's own permission prompts, while printing no
decision leaves them in force. This JSON contract replaces the legacy
top-level `"decision": "block"` form, and plain reminder text, which
Claude never sees for this event.

### 5.4 `PostToolUse`

**Purpose.** After model edits, prompt for the *consequent* updates
that ISO compliance and methodology §11 require. Every reminder goes out
as `additionalContext`, so the agent reads it. A `PostToolUse` hook
never denies anything, because the edit has already happened.

**Triggers:**

- After writing a `.feature` file, suggest mirroring each `@AC_` tag as
  a named criterion nested in the story (methodology §11.3).
- After editing a story file, suggest binding each new criterion with
  `verify <story>.acceptance.<name>` in a case stub, and checking the
  story's status against methodology §11.4.
- After editing a code path, where `test_first.applies` is `true`,
  suggest running the recorded `test_command`.
- After editing an interface or part def, suggest checking
  allocations.
- After editing a concern, suggest checking story coverage.
- After editing the Project Plan, suggest updating the Progress
  Status Record.

**Configuration:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/post-tool-use.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
payload=$(cat)
target=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
[[ -z "$target" ]] && exit 0

context() {
    jq -n --arg c "$1" '{hookSpecificOutput: {hookEventName: "PostToolUse",
        additionalContext: $c}}'
}

case "$target" in
    */stories/*.feature)
        context "[ISO/IEC 29110 follow-up] Feature changed. Mirror each @AC_ tag as a named criterion nested in the story's requirement :>> acceptance (methodology §11.3)."
        ;;
    */stories/*.sysml)
        context "[ISO/IEC 29110 follow-up] Story changed. Bind each new criterion with verify <story>.acceptance.<name> in a case stub (SR.O7), check StoryMeta.status against methodology §11.4, and regenerate the Traceability Matrix if a constraint changed."
        ;;
    */concerns/*.sysml)
        context "[ISO/IEC 29110 follow-up] Concern changed. Check that all framing stories still satisfy it, and update stakeholder communications if its scope shifted."
        ;;
    */logical-architecture/*.sysml)
        context "[ISO/IEC 29110 follow-up] Architecture changed. Update allocations if subsystem responsibilities shifted (SR.O3), re-render the Traceability Matrix, and write an ADR in docs/decisions/ for a non-trivial decision."
        ;;
    */docs/project-plan.md|docs/project-plan.md)
        context "[ISO/IEC 29110 follow-up] Project Plan changed. Per PM.O1 it needs Acquirer review and a referenced Change Request, and a new plan-baseline tag on merge."
        ;;
    *)
        # test_first_applies and is_code_path stand for the shipped
        # classification in lib/test-first.sh (methodology §11.5).
        if test_first_applies && is_code_path "$target"; then
            context "[ISO/IEC 29110 follow-up] Code changed. Run the recorded test_command and keep its output (methodology §11.7)."
        fi
        ;;
esac
```

### 5.5 `Stop`

**Purpose.** At the end of Claude's response, remind the operator to
capture decision rationale and follow-up tasks, and tell the agent when
code changed without a test.

**Contract.** A `Stop` hook that adds context for the agent makes Claude
continue the conversation, so the hook must never do it twice for the
same state, or the turn would loop.

- The hook reads `stop_hook_active` from its input and exits silently
  when it is `true`, which means a `Stop` hook already continued this
  turn.
- Reminders meant for the human go out as `systemMessage`. The human
  sees them, and they do not continue the conversation.
- Only the test-first finding uses `additionalContext`, so that the
  agent acts on it.
- The reminders go out once per session and per working-tree state,
  and so does the finding. The state is a checksum of `HEAD` and
  `git status`, and a marker file under `$TMPDIR` records what was said
  in it, with one line for the reminders and one for the finding. A
  second stop in a state already spoken in is silent. A finding that
  falls due in a state where only the reminders went out (after a
  switch from a refactor branch at the same commit, say) is still sent
  once.
- `Stop` keeps its marker at `${TMPDIR:-/tmp}/vse-stop.<session_id>`
  and `SubagentStop` keeps a separate one at
  `${TMPDIR:-/tmp}/vse-subagent-stop.<session_id>` (§5.6), so a
  subagent never uses up what the main agent is told.

**Configuration:**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script (`.claude/hooks/stop.sh`):**

```bash
#!/usr/bin/env bash
set -euo pipefail
payload=$(cat)

# A Stop hook already continued this turn. Saying more would loop.
[[ "$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')" == "true" ]] && exit 0

# Look at the changes in this session and prompt for ADR / report capture
recent_changes=$(git status --porcelain)
notes=""

# Architecture decision indicators
if echo "$recent_changes" | grep -qE '^.M (model/variations/|model/core/logical-architecture/)'; then
    notes+="[ISO/IEC 29110 prompt] Architectural changes detected. Per PM.3.3 and §10.5.3, consider an ADR in docs/decisions/ and an update to the trade-study analysis def. "
fi

# V&V execution indicators (verification report files modified)
if echo "$recent_changes" | grep -qE '^.M docs/.*verification-report'; then
    notes+="[ISO/IEC 29110 prompt] Verification activity detected. Per SR.O7, link the Verification Report to its IVV procedure and update the story's StoryMeta. "
fi

# Each thing is said once per session and working-tree state. The
# marker keeps a "reminders <state>" or "finding <state>" line for each
# thing said, so the finding still goes out in a state where only the
# reminders did. SubagentStop keeps its own marker (§5.6).
session=$(printf '%s' "$payload" | jq -r '.session_id // "none"')
marker="${TMPDIR:-/tmp}/vse-stop.$session"
state=$({ git rev-parse -q --verify HEAD || true; printf '%s' "$recent_changes"; } | cksum)
said() { grep -qxF -- "$1 $state" "$marker" 2>/dev/null; }

# Test first (methodology §11.9). test_first_applies and
# code_changed_without_test stand for the shipped helpers in
# lib/test-first.sh.
finding=""
if test_first_applies && code_changed_without_test && ! said finding; then
    finding="Code changed with no test change. Write the failing test before more code (methodology §11.7)."
    printf 'finding %s\n' "$state" >> "$marker"
fi
if [[ -n "$notes" ]] && ! said reminders; then
    printf 'reminders %s\n' "$state" >> "$marker"
else
    notes=""
fi

[[ -z "$finding$notes" ]] && exit 0
jq -n --arg c "$finding" --arg m "$notes" \
    '(if $c == "" then {} else {hookSpecificOutput: {hookEventName: "Stop", additionalContext: $c}} end)
     + (if $m == "" then {} else {systemMessage: $m} end)'
exit 0
```

### 5.6 `SubagentStop`

**Purpose.** When using Claude Code's subagent feature for parallel
work, aggregate compliance check results from each subagent.

```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/subagent-stop.sh"
          }
        ]
      }
    ]
  }
}
```

The subagent-stop script aggregates outputs from sub-tasks (each
working on a separate story branch, perhaps) and reports any
compliance issues to the orchestrating session.

It follows the §5.5 contract. It exits silently when `stop_hook_active`
is `true`, its reminders go out as `systemMessage`, and only the
test-first finding uses `additionalContext`. The reminders and the
finding each go out once per session and working-tree state. Its
marker, `${TMPDIR:-/tmp}/vse-subagent-stop.<session_id>`, is separate
from the `Stop` marker, so a subagent never uses up what the main agent
is told.

### 5.7 `PreCompact`

**Purpose.** Capture compliance state before context compaction so it
isn't lost from the rolling memory.

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-compact.sh"
          }
        ]
      }
    ]
  }
}
```

**Sample script:**

```bash
#!/usr/bin/env bash
set -euo pipefail
# Persist the current ISO state to a workspace file so post-compaction
# context can re-read it.
bash .claude/hooks/lib/iso-status.sh > /tmp/iso-state-snapshot.txt
echo "[ISO state snapshot saved to /tmp/iso-state-snapshot.txt]"
```

### 5.8 `Notification`

**Purpose.** Periodic compliance reminders (overdue risks, stale
Change Requests). These are unobtrusive and do not gate work.

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/notification.sh"
          }
        ]
      }
    ]
  }
}
```

## 6. CI hooks (covering what local hooks cannot)

Local git hooks fire on the developer's machine. Some checks are best
run on the canonical CI runner so that they cannot be bypassed and so
that their results are visible on the PR.

### 6.1 GitHub Actions example

`.github/workflows/compliance.yml`:

```yaml
name: ISO/IEC 29110 Compliance
on:
  pull_request:
    branches: [main, 'release/**']
  push:
    branches: [main]
    tags: ['release-*', 'plan-baseline-*']

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        # The full history, so a check over the change a pull request
        # or push brings can reach its base (§4.4).
        with: { fetch-depth: 0 }
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install -r tools/requirements.txt
      - name: Story well-formedness (§1.9)
        # --only wellformed runs the §1.9 rule set alone. The Gherkin
        # rule set is the precommit_gherkin gate, which the shipped
        # traceability-check.yml runs at its configured disposition.
        run: python3 tools/lint/story-wellformed.py --only wellformed model/
      - name: Plan completeness (§10.3.1)
        run: python3 tools/lint/plan-complete.py docs/project-plan.md
      - name: Traceability integrity (§9.8)
        # The renderer takes no arguments. Regenerate, then diff, the
        # way the shipped Contract 3 step does.
        run: |
          python3 tools/render/traceability-matrix.py
          git add --intent-to-add -- docs/generated/
          git diff --exit-code -- docs/generated/

  render:
    needs: lint
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { token: ${{ secrets.RENDER_BOT_TOKEN }} }
      - run: |
          python3 tools/render/traceability-matrix.py   # docs/generated/traceability-matrix.md
          python3 tools/render/stakeholder-reqs-doc.py  # docs/generated/stakeholder-requirements.md
          python3 tools/render/system-reqs-doc.py       # docs/generated/system-requirements.md
      - uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs: regenerate derived artefacts [skip ci]"
          file_pattern: 'docs/**/*.md'

  baseline-check:
    if: startsWith(github.ref, 'refs/tags/release-')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python3 tools/lint/baseline-integrity.py

  backup-mirror:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - name: Mirror to backup remote
        run: |
          git push --mirror ${{ secrets.BACKUP_REMOTE_URL }}
```

The `render` job creates the auto-commit that `post-merge` could not.
The `baseline-check` job blocks tag pushes that don't satisfy CM
integrity.

## 7. Hook orchestration

Hooks compose to enforce a workflow. A typical story lifecycle from a
hooks perspective:

```
1. Operator opens story branch:    story/US_042_AckFromDashboard
   → post-checkout fires, prints ISO status

2. Claude Code session opens
   → SessionStart fires, injects status

3. Operator: "Add the story for batch alarm acknowledgement"
   → UserPromptSubmit fires; story-creation reminder injected

4. Claude calls Edit on the story file
   → PreToolUse fires and finds no US_042_AckFromDashboard.feature
   → the edit is denied, and the reason names the expected file (§11.9)

5. Claude writes the feature file, then retries the story edit
   → PreToolUse finds the feature and its tag, adds the §1.9 reminder
   → PostToolUse fires and reminds about the verification case stub

6. Operator: "git commit -am 'feat(US_042): initial draft'"
   → pre-commit fires; runs lint, story well-formedness, Gherkin conformance
   → commit-msg fires; validates message format
   → commit succeeds

7. Operator pushes; opens PR
   → CI compliance.yml runs; lint + Traceability check

8. PR review, merge to main
   → post-merge fires locally on next pull; regenerates artefacts
   → CI render job commits regenerated artefacts on main

9. Release tag pushed
   → CI baseline-integrity check runs (§4.4 contract 4)
   → CI baseline-check job validates
   → CI backup-mirror job mirrors to backup remote
```

The path is forced through the right ISO obligations at each
checkpoint. The operator sees ISO status at session start, gets
nudges during authoring, and is blocked when proceeding would land
non-compliant state on a protected reference. The agent is also stopped
earlier, at the edit, when it would write a story before its feature
file or code before its test (methodology §11.9).

## 8. Configuration file (`.iso-config.yaml`)

A single project-level configuration file drives the hook behaviour:

```yaml
# .iso-config.yaml — ISO/IEC 29110 hook configuration

# Project rigour profile per methodology section 0.10.
# One of: light | standard | full. Absent means standard.
# This sample shows the full-profile surface. The standard and light
# defaults carry lighter baselined_paths and storymeta sets
# (methodology section 0.10.3).
project_profile: full

# SysML v2 toolchain for the lint gate and CI: syside | omg-pilot | opensysml.
# Absent means syside. Hooks fall back along that order when the tool is unavailable.
sysml_toolchain: syside

# Optional per-gate overrides: block | warn | info | off.
# Unset keys follow the profile default (section 0.10.4).
# The last four gates block at every profile. Lowering one is a
# tailoring decision with a recorded reason (section 11.10).
# gate_overrides:
#   commit_msg_pattern: warn
#   commit_msg_cr_reference: block
#   precommit_lint: warn
#   precommit_story_wellformed: off
#   precommit_traceability: warn
#   precommit_gherkin: block
#   precommit_test_first: block
#   pretooluse_gherkin_first: block
#   pretooluse_test_first: block

# Test-first record per methodology section 11.5. The values below
# describe a project with Python code. A project with no implementation
# code records applies: false and a rationale saying so.
test_first:
  applies: true
  rationale: "pytest under tests/. bash scripts: bats viable. SysML: not viable, no execution runtime."
  test_command: "pytest -q"
  scenario_command: "behave model/core/stories"   # optional
  code_paths: [src/*, scripts/*.sh]               # globs relative to the git toplevel
  test_paths: [tests/*]
  refactor_branches: [refactor/*]

baselined_paths:
  - docs/project-plan.md
  - docs/cm-strategy.md
  - model/library/

protected_branches:
  - main
  - release/*

storymeta:
  required_fields: [points, priority, status]
  valid_statuses: [backlog, ready, inProgress, done]

risk_register:
  stale_threshold_days: 30
  path: docs/risk-register.md

change_request:
  issue_label: change-request
  required_for_paths: ${baselined_paths}

renderers:
  traceability_matrix:    tools/render/traceability-matrix.py
  stakeholder_reqs:       tools/render/stakeholder-reqs-doc.py
  system_reqs:            tools/render/system-reqs-doc.py
```

The hook scripts read this file to determine what to enforce. Two
conventions govern the schema. It stays flat and at most two levels
deep, so the shipped hooks can parse it with the same awk idiom they
already use rather than taking a YAML library dependency. Lists under a
section, such as `code_paths`, are written inline (`[a, b]`) for the
same reason. And every project-specific behaviour belongs here rather
than in a script, per §10, so an upgrade replaces the scripts without
touching the project's intent.

The `test_first` block is the first of the four records methodology
§11.5.3 requires, and its keys are specified in §11.5.2. Because an
edit to `gate_overrides` or `test_first` changes what the gates
enforce, the `PreToolUse` hook asks a human to confirm it (methodology
§11.10).

The `baselined_paths` list shown above is the `standard`-and-above
default. The per-profile defaults are in methodology §0.10.3. Note that
`methodology/` is deliberately absent at every profile, including
`full`, because Change Request protection on the project-local
methodology copy contradicts the override convention that makes the copy
useful. A project under formal assessment adds it back explicitly.

## 9. Setup checklist

For a new project adopting this methodology + ISO/IEC 29110 compliance:

- [ ] Repository scaffolded per §8.3 of methodology.
- [ ] `.githooks/` populated with scripts from §4 of this guide;
      `git config core.hooksPath .githooks` run.
- [ ] `tools/lint/` and `tools/render/` populated with project-
      specific implementations.
- [ ] `tools/lint/story-wellformed.py` and its Gherkin parser installed
      (methodology §11.9.1).
- [ ] `test_first` recorded in the four places of methodology §11.5.3
      (`/vse-test-first`).
- [ ] Every story has its `<ID>.feature` beside it (methodology §11.2).
- [ ] `.claude/settings.json` configured with hooks per §5;
      `.claude/hooks/` populated with scripts.
- [ ] `.iso-config.yaml` authored per §8.
- [ ] `.github/workflows/compliance.yml` deployed per §6.1.
- [ ] Branch protection enabled on `main` and `release/*`
      (no force-push, required PR review, required status checks).
- [ ] Backup remote configured; mirroring tested.
- [ ] CODEOWNERS file in place mapping ISO roles to git identities.
- [ ] `docs/project-plan.md` authored and baselined
      (PR through full review cycle).
- [ ] Initial Risk Register, Correction Register, Disposal Approach
      sections in place.
- [ ] First Progress Status Record created.

## 10. Customisation guidance

The hooks specified here are a *baseline*. Project sets will adjust
them based on:

- **Tool stack.** A project using the Eclipse SysML v2 tooling may
  invoke its CLI for lint instead of a custom Python linter.
- **Issue tracker.** The `gh` CLI is GitHub-specific; GitLab projects
  use `glab`; other trackers need their own integration.
- **Renderer technology.** The renderers are Python here; they could
  equally be Node, Bash, or a single SysML v2 model-query tool.
- **Iteration cadence and granularity.** A 1-week-iteration project
  may need more frequent regeneration than the post-merge default.

Two patterns work well for customisation:

- **Override before extend.** When the standard hook doesn't fit,
  override it locally in `.githooks-local/` (gitignored) and have the
  versioned `.githooks/` scripts source the local override if
  present.
- **Configuration over code.** Push project-specific behaviour into
  `.iso-config.yaml` rather than into the scripts. The scripts stay
  the same across projects; the config differs.

## 11. Failure modes and how to handle them

| Failure | Symptom | Fix |
|---|---|---|
| Hook script not executable | Commits or pushes succeed without checks running | `chmod +x .githooks/*` |
| `core.hooksPath` not set | Same as above | `git config core.hooksPath .githooks` |
| Renderer slow at scale | `pre-commit` takes >5 s | Move heavy checks to CI (§4.4); keep `pre-commit` to fast lint only |
| Claude Code hooks not firing | No status injected at session start | Verify `.claude/settings.json` schema matches current docs; check shell scripts are executable |
| Lifecycle hooks switched off | No in-session gate fires, although the hooks are configured | Check for `disableAllHooks` in the settings, a session started with `--bare`, or a disabled plugin. The `pre-commit` gates and CI still run the same checks (methodology §11.11) |
| Lifecycle hook output ignored | A reminder or denial printed by `PreToolUse`, `PostToolUse`, `Stop` or `SubagentStop` never reaches Claude | Print exactly one JSON object on stdout and send diagnostics to stderr (§5). Plain stdout reaches Claude only for `SessionStart` and `UserPromptSubmit` |
| `PreToolUse` denies a story edit | The reason names a missing `<ID>.feature` or a missing `@<ID>` tag | Write the feature file first, with the story tag and the narrative (methodology §11.2). For a story in the pre-5.0.0 form, formalise its existing Given/When/Then text without adding behaviour |
| `PreToolUse` denies a code edit | The reason says no test change was found, or that a shallow clone or detached HEAD gives no branch evidence | Write or change the failing test first (methodology §11.7). In CI or a shallow clone, fetch the full history. Restructuring without a behaviour change belongs on a `refactor/` branch |
| Edit made through the Bash tool | A file written by a redirect, `sed -i` or a script reaches the working tree without any in-session gate seeing it | `PreToolUse` sees only the file tools it is registered for (methodology §11.11). The `pre-commit` gates and CI are the backstop, because they check what is committed whichever tool wrote it. An agent never writes a denied file through the Bash tool (methodology §11.10) |
| `jq` and `python3` both missing | Every in-session gate lets edits through with a notice | Install `jq`. Until then the `pre-commit` gates and CI are the only check (methodology §11.11) |
| Preferred SysML toolchain unavailable (licence expired, no Java 21, binary missing) | `pre-commit` prints `<tool> unavailable (...); validating with <next> instead`, or at `block` refuses with "No SysML toolchain is available" | Run `/vse-toolchain` to install or switch, or lower the gate with `gate_overrides.precommit_lint` |
| False positives blocking valid work | `pre-commit` blocks legitimate edits | Review `.iso-config.yaml` first, since the finding is usually a configuration problem. Lower the gate with a `gate_overrides` entry (methodology §0.10.4) rather than editing the script. For the single occurrence, bypass with a recorded rationale per methodology §0.10.6 |
| Local gate bypassed | A commit lands without the gate having run | This is a supported act, not a failure, provided the rationale is recorded per methodology §0.10.6 (Correction Register at `full`, commit body otherwise). An unrecorded bypass is the actual failure mode. Put any gate that must not be bypassable in CI instead |

The key principle: **local hooks are fast feedback, and CI is where an
unbypassable gate belongs.** A local hook runs on a workstation the
engineer controls, so its authority is the engineer's cooperation plus
the recording obligation of §0.10.6. A required status check on a
protected branch does not depend on cooperation. Design the gate set
with that division in mind, and put the checks that protect the audit
trail on the CI side.

Doing so is project work, not plugin work. The plugin ships one CI
implementation, `templates/github/traceability-check.yml`, installed at
every profile (§3.4). Its pre-commit step carries the gate dispositions
from `.iso-config.yaml`, including the Gherkin-first and test-first
gates. Its model-validation and Contract 3 freshness steps are advisory
at `light` and `standard` and blocking at `full`. Its test and scenario
steps fail the workflow at every profile where test first applies, and
so does a record where test first applies without its `test_command`
(methodology §11.5.2). Its formatting check is always advisory.
Contracts 1 and 4 in §4.4 are documented
specifications that the project implements against its own CI platform,
because each depends on the project's tag pattern, renderer choice, and
configuration-management scope.

## 12. Out of scope of this guide

- Specific implementations of the lint and render scripts. The
  contracts are stable; the implementations are project-determined.
- Tooling for ISO/IEC 29110 *assessment* per ISO/IEC TR 29110‑3. The
  hooks here keep the project compliant; an external assessor still
  performs the formal audit.
- Migration from a non-hook-driven legacy project. Adoption strategy
  is project-set-determined; a phased rollout (lint first, then
  baseline protection, then derived artefact generation) is usually
  more humane than a big-bang switch.

---

*End of hooks guide. Companion documents: methodology §0 to §11. The
guide is updated whenever methodology compliance obligations change
or Claude Code hook APIs evolve.*
