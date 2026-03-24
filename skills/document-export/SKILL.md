---
name: document-export
description: Generate non-diffable output files (docx, pptx, pdf) from markdown work product sources. All outputs go to build/ (gitignored).
user-invocable: true
---

# Document Export

You are the document export skill. You generate formatted output files from
the markdown work product templates that live in `docs/`. The key principle
is that markdown files in git are the source of truth; generated files are
ephemeral build artefacts.

## When This Skill Triggers

- The user asks to export, generate, or produce a document (docx, pptx, pdf)
- The user asks to "build" or "publish" work products
- The user asks for a deliverable-ready version of a work product
- The `@lifecycle-orchestrator` routes here for document generation at delivery

## Principle: Source of Truth

```
docs/*.md  ──(export)──>  build/*.docx
   │                         │
   │  diffable, committed    │  not diffable, gitignored
   │  human-editable         │  formatted for delivery
   └─ source of truth        └─ generated artefact
```

Never modify the source markdown files. This skill only reads from `docs/`
and writes to `build/`.

## Step 1: Detect Available Tools

Check which export tools are available, in order of preference:

### For DOCX
1. **document-skills plugin** (`@docx` skill): preferred if available
2. **pandoc**: `pandoc --version` to check availability
3. **Manual**: inform the user that no export tool is available

### For PPTX
1. **document-skills plugin** (`@pptx` skill): preferred if available
2. **pandoc**: can produce basic pptx from markdown
3. **Manual**: inform the user that no export tool is available

### For PDF
1. **document-skills plugin** (`@pdf` skill): preferred if available
2. **pandoc with LaTeX**: requires a LaTeX engine (pdflatex, xelatex, or lualatex)
3. **pandoc with wkhtmltopdf**: HTML intermediate
4. **Manual**: inform the user that no export tool is available

Report which tools are available before proceeding.

## Step 2: Select Files to Export

Ask the user what to export:

1. **Single file**: "Export the Project Plan" produces `build/project-plan.docx`
2. **Category**: "Export all PM documents" produces all `docs/pm/*.md` as docx
3. **All**: "Export everything" produces all `docs/pm/*.md` and `docs/sr/*.md`

Map document names to file paths:

| Name | Source Path |
|------|------------|
| Project Plan | docs/pm/project-plan.md |
| Progress Status | docs/pm/progress-status.md |
| Meeting Record | docs/pm/meeting-record.md |
| Change Request | docs/pm/change-request.md |
| Correction Register | docs/pm/correction-register.md |
| Product Acceptance | docs/pm/product-acceptance.md |
| SEMP | docs/sr/semp.md |
| StRS | docs/sr/stakeholder-requirements.md |
| SyRS | docs/sr/system-requirements.md |
| Traceability Matrix | docs/sr/traceability-matrix.md |
| System Design | docs/sr/system-design.md |
| IVV Plan | docs/sr/ivv-plan.md |
| Verification Report | docs/sr/verification-report.md |
| Validation Report | docs/sr/validation-report.md |
| Maintenance Guide | docs/sr/maintenance-guide.md |

## Step 3: Ensure Build Directory

```bash
mkdir -p build
```

Verify that `build/` is in `.gitignore`. If not, warn the user.

## Step 4: Export Using Available Tool

### Using document-skills Plugin

If the document-skills plugin is available, delegate to it:

- For docx: invoke `@docx` with the source file path
- For pptx: invoke `@pptx` with the source file path
- For pdf: invoke `@pdf` with the source file path

Move the output to `build/` if the plugin does not place it there automatically.

### Using Pandoc

For each file to export:

**DOCX:**
```bash
pandoc docs/pm/project-plan.md \
  -o build/project-plan.docx \
  --from markdown \
  --to docx \
  --metadata title="Project Plan"
```

If a reference template exists at `templates/reference.docx`, add:
```bash
  --reference-doc=templates/reference.docx
```

**PPTX:**
```bash
pandoc docs/pm/progress-status.md \
  -o build/progress-status.pptx \
  --from markdown \
  --to pptx
```

**PDF:**
```bash
pandoc docs/pm/project-plan.md \
  -o build/project-plan.pdf \
  --from markdown \
  --to pdf \
  --pdf-engine=xelatex
```

### YAML Frontmatter Handling

The YAML frontmatter in each markdown file contains metadata (project, version,
date, author, status). Pandoc reads this automatically for document metadata.
If using another tool, strip the frontmatter before processing or pass the
metadata separately.

## Step 5: Report Results

Present the export results:

```
DOCUMENT EXPORT
===============
Format:  DOCX
Tool:    pandoc 3.1.13
Output:  build/

Exported:
  [x] build/project-plan.docx         (42 KB)
  [x] build/progress-status.docx      (18 KB)
  [ ] build/meeting-record.docx       (FAILED: ...)

Total: 2/3 files exported successfully
```

## Batch Export

When the user asks to "export all work products" or "build all documents":

1. Enumerate all `.md` files in `docs/pm/` and `docs/sr/`
2. Export each to the requested format (default: docx)
3. Place all outputs in `build/`
4. Report results

## Error Handling

- If pandoc is not installed and no plugin is available, inform the user and
  suggest installing pandoc: `sudo apt install pandoc`
- If a source file does not exist, skip it and report it as missing
- If the export fails for a specific file, continue with remaining files
  and report failures at the end
- If `build/` is not in `.gitignore`, warn that generated files may
  accidentally be committed

## Cross-References

- `@project-setup`: creates the directory structure including `build/`
- `@lifecycle-orchestrator`: may trigger export at SR.6 delivery
- `document-skills:docx`, `document-skills:pptx`, `document-skills:pdf`:
  preferred export tools when available
- `templates/pm/`, `templates/sr/`: original templates (source files are
  in `docs/pm/` and `docs/sr/` after project setup)
