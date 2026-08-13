---
paths:
  - "methodology/**"
---

# Methodology Rules

`methodology/` holds the canonical specification of the process the
plugin enforces (§0 to §10 plus the ISO 29110 hooks guide). It is the
source of truth for every workflow stage, and skill bodies and wiki
pages may summarise it but never override it. Where any source
disagrees, the methodology wins, and ISO/IEC 29110 is the process
backbone beneath it (§9 maps the compliance obligations).

- The methodology ships into each user project as a copy at
  `<project>/methodology/`. A skill consults the project-local copy
  first and falls back to `${CLAUDE_PLUGIN_ROOT}/methodology/`. The
  project-local copy wins for that project.
- The methodology is not a wiki layer. Do not move sections into
  `wiki/pages/`. The wiki may carry summaries that link back.
- Update `methodology/README.md` whenever a section file is added or
  removed, since it documents the override convention for end users.
- Substantive changes get elevated review: no section may contradict
  the ISO 29110 §6 or §7 obligations as documented in §9. Tailoring
  lives in §0.10 (profiles, gate dispositions, bypass with rationale),
  not in weakening obligations elsewhere.
- Hooks implement the spec. If the hooks lag behind a spec change, the
  implementation is wrong, not the spec.
