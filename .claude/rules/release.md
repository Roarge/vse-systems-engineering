---
paths:
  - "CHANGELOG.md"
  - ".claude-plugin/**"
---

# Versioning and Release

- Bump `version` in `.claude-plugin/plugin.json` AND
  `.claude-plugin/marketplace.json` in lockstep on every landed change,
  even documentation-only ones, so installers detect updates. CI checks
  the two match.
- **Patch** for fixes, docs, and chores. **Minor** for new skills, new
  hooks, or material new behaviour in an existing skill. **Major** only
  for breaking changes to skill names, hook contracts, or the manifest
  surface.
- `CHANGELOG.md` follows Keep a Changelog. Under `[Unreleased]`,
  qualify repeated category headings with a short parenthetical, for
  example `### Added (papers ingest)`, so anchors stay unique.
- **Release-candidate trains**: during a multi-PR train the next rc
  number is assigned at merge time, not planned in advance. The
  `[Unreleased]` preamble records which rc each landed slot took.
  Issues may name stale rc numbers, and the preamble is the authority.
- The version bump and changelog entry are the final commit on the
  feature branch that justifies them (see the git-workflow rules),
  never a separate PR.
