# Methodology Specification

This directory holds the canonical methodology specification that the
`vse-systems-engineering` plugin enforces. The methodology is an
agile model-based systems engineering (MBSE) process built on three
substantive changes from Harmony aMBSE (Douglass, 2016, 2021):

1. User stories are the canonical stakeholder-intent artefact at every
   stage. A `UserStory` specialises `requirement def`.
2. SysML v2 throughout. No SysML v1 stereotypes.
3. Base Architecture and System Context are foundational artefacts
   that precede stakeholder work.

## Override convention

Each section is a self-contained markdown document. Every project
that adopts this plugin receives a copy of the directory at
`<project>/methodology/`. The project-local copy is authoritative
for that project, so a project may modify the process without
touching the plugin.

Skills inside the plugin resolve the methodology spec by reading
the project-local copy first, then falling back to
`${CLAUDE_PLUGIN_ROOT}/methodology/<file>.md` when no project-local
file exists. The pattern is the same as for any other override
mechanism in Claude Code: project-local files win.

## Document map

| File | Section | Status |
|---|---|---|
| `00-methodology-overview.md` | §0 Methodology Overview | drafted |
| `01-user-stories.md` | §1 User Stories | drafted |
| `02-base-architecture.md` | §2 Base Architecture | drafted |
| `03-system-context.md` | §3 System Context | drafted |
| `04-stakeholder-requirements.md` | §4 Stakeholder Requirements Engineering | drafted |
| `05-system-requirements.md` | §5 System Requirements Definition and Analysis | drafted |
| `06-architectural-analysis.md` | §6 Architectural Analysis and Trade Studies | drafted |
| `07-architectural-design.md` | §7 Architectural Design | drafted |
| `08-project-structure.md` | §8 Project Structure and Git Workflow | drafted |
| `09-iso-29110-compliance.md` | §9 ISO/IEC TR 29110‑5‑6‑2 Compliance | drafted |
| `10-project-management.md` | §10 Project Management | drafted |
| `iso-29110-hooks-guide.md` | Companion implementation guide for hook automation | drafted |

## Editing the spec

The plugin contributor edits files in this directory directly,
following the conventions in `CLAUDE.local.md`. Each substantive
edit is reviewed under the same pull-request workflow as any other
plugin change.

The eventual SysML v2 library packaging of the methodology
(per §0.8) lives under `templates/common/library/` and the
`<project>/model/library/` location once a project is set up. The
markdown spec in this directory remains the design input for that
library; the library is its machine-readable counterpart.

## Worked examples

Worked-example appendices (§A–§C of the spec) are deferred until a
project example domain is fixed. The plugin's demo
(`demo/smart-sensor/`) supplies a worked example in the meantime,
and the §A–§C drafts are written against that demo when ready.
