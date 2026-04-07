---
description: Bootstrap a new VSE systems engineering project (greenfield or brownfield)
argument-hint: "[optional notes about the project]"
---

Invoke the `vse-systems-engineering:project-setup` skill to bootstrap a VSE
systems engineering project aligned with ISO/IEC 29110.

Pass the user-supplied arguments through as additional context for the skill:

$ARGUMENTS

The skill will detect whether the current directory is empty (greenfield) or
already a git working tree (brownfield), gather context, and enter Plan Mode
for review before making any file system changes. It is best run on Claude
Opus with extended thinking.

Brownfield projects may enter the lifecycle at any centre-of-gravity activity,
not just PM.1 plus SR.1. The skill will detect existing work products and
propose an entry point based on what is already in the repository. See
`knowledge/iteration-centred-operation.md` for the brownfield entry rules.
