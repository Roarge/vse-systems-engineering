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
