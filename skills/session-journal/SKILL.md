---
name: session-journal
description: Manage cross-session continuity journal. Use when saving progress, checking what was done last session, or creating a checkpoint.
user-invocable: true
---

# Session Journal

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

You manage the `.vse-journal.yml` file, which provides cross-session continuity
for VSE systems engineering projects. The journal records what was done in each
session, what decisions were made, and what the engineer should work on next.

## When This Skill Triggers

- The engineer runs `/vse-journal` or invokes `@session-journal` directly
  (checkpoint mode)
- The engineer says "checkpoint", "save progress", or "what did I do?"
- Work driven from `@story-orchestrator` or `@release-orchestrator` reaches a
  natural pause and a continuity record is worth writing (resume or close mode)

## Detecting a VSE Project

This skill only operates inside a VSE project. Detect one the same way
`hooks/session-start.sh` does: a `methodology/` folder at the project root
(the greenfield default), or an `engineering/methodology/` folder (the
brownfield default). When neither is present, say so and stop rather than
writing a journal into a repository that is not under the methodology.

## Journal File Format

The journal lives at `.vse-journal.yml` in the project root. It uses a rolling
window (default 15 entries, newest first). Each entry has this structure:

```yaml
sessions:
  - date: "YYYY-MM-DDTHH:MM:SS"
    story: "US-014"
    activities: [SR.2.2, SR.2.3, SR.3.1]
    summary: >
      Brief description of what was accomplished.
    work_products_changed:
      - path/to/changed/file
    decisions:
      - "Key decision and rationale"
    next_steps:
      - "Actionable next step"
    open_issues: []
```

## Mode 1: Resume (Read)

Triggered when the engineer asks what happened last session, or when work
resumes inside a story or release context. Read `.vse-journal.yml` and present
the SESSION CONTINUITY block.

### Procedure

1. Read `.vse-journal.yml` from the project root
2. If the file does not exist or has no sessions, skip silently (backward
   compatible with projects created before this feature)
3. Extract the most recent session entry (first item in `sessions` list)
4. Calculate time elapsed since the last session
5. Present the continuity block:

```
SESSION CONTINUITY
  Last session:  [date] ([N days/hours ago])
  Summary:       [summary from last entry]
  Pending:
    1. [next_step 1]
    2. [next_step 2]
    ...
  Open issues:   [open_issues, or "None"]
```

6. If there are `open_issues`, flag them prominently:
   "There are unresolved issues from the previous session that need attention."

## Mode 2: Checkpoint (Manual Write)

Triggered when the engineer explicitly requests a progress save.

### Procedure

1. Review the current conversation to identify:
   - **Story**: the open story, taken from the current
     `story/<US_id>_<short>` branch name and confirmed against the matching
     story file. Record `(none)` when the work is not on a story branch
   - **Activities**: which ISO 29110 sub-activities were worked on (use codes
     like SR.2.3, PM.1.5, etc.)
   - **Summary**: 1-3 sentences describing what was accomplished
   - **Work products changed**: list file paths of created or modified work
     products (models, docs, TASKS.md)
   - **Decisions**: key decisions made during the session with brief rationale
   - **Next steps**: concrete, actionable items the engineer should work on
     next (ordered by priority)
   - **Open issues**: unresolved questions, blockers, or items deferred to
     a future session

2. Present the draft entry to the engineer for review:
   "Here is the session journal entry I will save. Would you like to adjust
   anything?"

3. On approval, read the current `.vse-journal.yml`

4. Prepend the new entry to the `sessions` list (newest first)

5. Check the rolling window: if `len(sessions) > window_size`, archive the
   overflow entries (see Archive Rotation below)

6. Write the updated `.vse-journal.yml`

7. Confirm: "Session checkpoint saved. [N] entries in journal."

## Mode 3: Close (Automatic Write)

Triggered at the end of an SE session, when the conversation is wrapping up.

### Procedure

1. Detect that the conversation is wrapping up (the engineer says "thanks",
   "that is all", "done for now", or similar)

2. Prompt the engineer: "Shall I save a session checkpoint before we finish?"

3. If the engineer agrees, follow the same procedure as Mode 2 (Checkpoint)

4. If the engineer declines, skip without writing

### Wrap-Up Detection

Watch for these signals:
- Explicit farewells: "thanks", "that is all", "done for now", "bye"
- Task completion: all items in the current work plan are done
- Story transition: the engineer has just closed or baselined a story

## Archive Rotation

When the `sessions` list exceeds `window_size` (read from the YAML file,
default 15):

1. Identify entries beyond the window (from the end of the list, since newest
   entries are at the front)
2. Read `docs/pm/session-archive.yml` (create if it does not exist)
3. Append the overflow entries to the archive's `sessions` list
4. Remove the overflow entries from `.vse-journal.yml`
5. Write both files

Archive file format:

```yaml
# docs/pm/session-archive.yml
# Archived session journal entries.
# These entries were rotated out of .vse-journal.yml.

sessions:
  - date: "..."
    # ... same structure as active journal entries
```

## Activity Code Reference

When mapping conversation actions to ISO 29110 activity codes, use this
reference:

| Code | Activity |
|------|----------|
| PM.1.1-PM.1.19 | Project Planning sub-tasks |
| PM.2.1-PM.2.7 | Plan Execution sub-tasks |
| PM.3 | Assessment and Control |
| PM.4 | Closure |
| SR.1 | Initiation (SEMP, data model, environment) |
| SR.2.1 | Review Project Plan with Work Team |
| SR.2.2 | Elicit and capture stakeholder needs |
| SR.2.3 | Derive system requirements from needs |
| SR.2.4 | Derive system element requirements |
| SR.2.5 | Establish IVV Plan |
| SR.2.6 | Update Traceability Matrix |
| SR.3.1 | Develop functional architecture |
| SR.3.2 | Develop physical architecture |
| SR.3.3 | Define interfaces |
| SR.3.4 | Evaluate trade-offs |
| SR.4.1 | Construct system elements |
| SR.4.2 | Integrate elements |
| SR.4.3 | Verify elements |
| SR.4.4 | Correct defects |
| SR.5.1 | Integrate system |
| SR.5.2 | Verify system |
| SR.5.3 | Validate system |
| SR.6.1 | Product review |
| SR.6.2 | Maintenance documentation |
| SR.6.3 | Training specifications |
| SR.6.4 | Verify maintenance and training documents |
| SR.6.5 | Perform delivery |
| SR.6.6 | Transition to manufacturing and support |

## Cross-References

- `/vse-journal`: the slash command that invokes this skill directly
- `@story-orchestrator` and `@release-orchestrator`: the work contexts a
  continuity record is usually written from
- `@project-setup`: creates the initial empty `.vse-journal.yml`
- `methodology/` (project root) or `engineering/methodology/`: the marker that
  identifies a VSE project, matching `hooks/session-start.sh`
- `docs/pm/session-archive.yml`: archive for rotated journal entries

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. No wiki page routes
to this skill directly. When reference material is needed, consult `INDEX.md`
at the wiki root and read the named page on demand with the Read tool. Do not
bulk-load.
