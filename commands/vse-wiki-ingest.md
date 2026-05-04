---
description: Ingest a source file into atomic wiki pages with the VSE wiki pipeline
argument-hint: "<path to source under sources/ or scratch markdown>"
---

Invoke the `vse-systems-engineering:vse-wiki-ingest` skill to process a
new source into atomic pages under `wiki/pages/`, regenerate affected
bundles, update `wiki/INDEX.md`, and append to `wiki/LOG.md`.

Pass the user-supplied arguments through as additional context for the
skill:

$ARGUMENTS

The skill converts PDFs via the `markitdown` skill from the
`claude-scientific-writer` plugin if available, then dispatches the
`vse-wiki-ingestor` subagent for a suggestion-shaped decomposition
proposal. No files are written until the contributor approves the
proposal. The skill runs only inside the `vse-systems-engineering`
plugin repo with an initialised wiki.
