---
name: sysml-toolchain
description: Choose, install, verify, and switch the SysML v2 validation toolchain (Syside, OMG SysML v2 Pilot Implementation, Open-MBEE OpenSysML) recorded as sysml_toolchain in .iso-config.yaml. User-level installs after per-step approval. Use when a hook or CI prints a fallback notice, a Syside licence expires, Java 21 is missing, or the toolchain key is not recorded.
when_to_use: Use when asked which SysML tool to use, to install or update the pilot, OpenSysML, or Java, to switch toolchains, when pre-commit prints "<tool> unavailable" or "No SysML toolchain is available", when the session banner says a fallback applies, when project-audit Check 16 warns, or when wiring .lsp.json for an editor server.
user-invocable: true
---

# SysML Toolchain

If the VSE lens (vse-companion-overview) is not yet loaded this session, load it first.

You are the skill that owns the SysML v2 toolchain of a project: which validator the hooks and the CI run, whether it is installed and usable, and how the editor reaches a language server. Three toolchains are supported. Sensmetry Syside is the commercial toolchain with a formatter, lint rules and a language server. The OMG SysML v2 Pilot Implementation is the reference implementation, driven in batch mode on a Java 21 runtime. Open-MBEE OpenSysML is a single static binary with a language server. The project records its preference as the flat key `sysml_toolchain` in `.iso-config.yaml` (`syside`, `omg-pilot`, or `opensysml`, absent means `syside`), and the shared library `hooks/lib/sysml-toolchain.sh` reads it, probes availability, validates, and falls back along the fixed order syside, omg-pilot, opensysml with one notice naming why.

This skill has read-write behaviour inside the project: `.iso-config.yaml`, the managed block of `CLAUDE.md`, `docs/semp.md`, `docs/project-plan.md`, `.lsp.json`, and `.githooks/lib/sysml-toolchain.sh`. After a separate approval per step it installs software user-level under `~/.local/share/sysml-pilot` and `~/.local/bin`. A system package manager runs only with explicit approval of that step, and only for Java.

## When This Skill Triggers

- The user asks which SysML v2 tool to use, or asks to install, update, verify, or switch one.
- The pre-commit hook printed `<tool> unavailable (...)` with a fallback notice, or `No SysML toolchain is available`.
- The SessionStart banner reports the preferred toolchain as unavailable.
- `@project-audit` Check 16 reported the key as absent, unrecognised, or the tool as unavailable.
- `@project-setup` hands off after a scaffold whose chosen toolchain was not detected.
- The user asks how the editor reaches a language server, or why `.sysml` files show as plain text.
- `@sysml2-modelling` routes a tooling installation or configuration question here.

Arguments: `status` reports and stops. `install <tool>` runs the detection report and the install offers for that tool. `switch <tool>` records that tool after the detection report without asking the question. No argument runs the whole workflow.

## Step 1: Read the Recorded Preference

Locate `.iso-config.yaml` at the project root, then under `engineering/`. If `sysml_toolchain` is present, read it, report it, and do not ask. If it is absent, say that the hooks and the CI treat an absent key as `syside`, and continue to Step 3 unless the argument was `status`.

## Step 2: Detection Report

Run, from the project root, `${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh status`, then `detect syside`, `detect omg-pilot`, `detect opensysml`, and `java`. Each `detect` exits 0 when the tool is usable and 2 with the reason on stderr otherwise. The Syside probe runs a real `syside check` on a one-line scratch model under a temporary directory, because `syside --version` and `syside check --help` succeed on an expired licence and only a real check reveals `License check failed`.

Present one table: Tool, Found, Version, Status, Reason. Version commands: `syside --version` (works without a licence), `java -version 2>&1 | head -n 1`, `sysml -version | head -n 1` (a build from `go install` prints `sysml dev`, which is accepted), and `ls ~/.local/share/sysml-pilot/sysml/jupyter-sysml-kernel-*-all.jar`. Also report the `command` in `.lsp.json` if the file exists, whether `syside.toml` exists, and whether `.githooks/lib/sysml-toolchain.sh` exists beside `.githooks/lib/iso-profile.sh`.

With the argument `status`, stop after the table.

## Step 3: The Toolchain Question

Offer the three toolchains with these one-line glosses, verbatim:

- **`syside`.** Sensmetry Syside CLI. Commercial licence (Solo or Business), formatter and language server included, licence-server validation. Solo excludes CI and air-gapped use.
- **`omg-pilot`.** OMG SysML v2 Pilot Implementation, the reference implementation (EPL-2.0). Needs Java 21 or later. Strictest conformance. No formatter, no language server. About 10 to 15 seconds per validation run.
- **`opensysml`.** Open-MBEE OpenSysML (Apache-2.0, one static binary). Sub-second validation, language server included, no formatter. Younger than the pilot and slightly more permissive.

**No default is forced.** If the engineer declines to choose, do not write the key. Say what an absent key means, say that the hooks fall back automatically to whichever tool is installed, and stop after the report.

**A recorded key is not revisited.** With the argument `switch <tool>` the question is skipped and `<tool>` is recorded. Without it, a present key is read and the skill moves to Step 5 for that tool.

## Step 4: Record the Choice

Four writes, each shown before it is made:

1. `.iso-config.yaml`: set `sysml_toolchain: <tool>` after `project_profile`, keeping the shipped comment block. The key is flat and top-level so the awk reader in the hooks finds it.
2. `CLAUDE.md`, inside the managed block between `<!-- BEGIN VSE COMPANION (managed by project-setup) -->` and `<!-- END VSE COMPANION -->` only: set the `- **Toolchain:**` line in the Project facts list, inserting it after the Profile line when absent. Never edit outside the markers.
3. `docs/semp.md`, when the file exists: the Modelling tool bullet and the tools table row name the toolchain and its version (`Sensmetry Syside` and the project's pinned release, `OMG SysML v2 Pilot Implementation` and `release 2026-07 (kernel 0.61.0)`, or `Open-MBEE OpenSysML` and `v0.6.0`). Methodology §10.3.2 obliges the SEMP to record the engineering tools.
4. `docs/project-plan.md`, tailoring record: append `Toolchain: <tool> (recorded <date>, previously <old value or "not recorded">).`, keeping the earlier line so the history stays readable.

Then the editor wiring. `.lsp.json` at the project root is read by the Claude Code IDE, not by any hook:

- `syside`: copy `${CLAUDE_PLUGIN_ROOT}/templates/common/lsp.json` (launches `syside lsp`).
- `opensysml`: copy `${CLAUDE_PLUGIN_ROOT}/templates/common/lsp-opensysml.json` (launches `sysml-lsp -stdio -strict`).
- `omg-pilot`: the pilot ships no language server. If `command -v sysml-lsp` succeeds, copy `lsp-opensysml.json` and say that the editor server is OpenSysML's while the commit gate is the pilot. Otherwise write no `.lsp.json`, and say that `.sysml` files show as plain text until OpenSysML is installed.

If an existing `.lsp.json` differs from both templates, show the diff and ask before overwriting. `syside.toml` stays in place when switching away from Syside (the hooks do not read it), with an offer to remove it. The scaffold copies it only for `syside` or when no toolchain was chosen. If `.githooks/lib/iso-profile.sh` exists but `.githooks/lib/sysml-toolchain.sh` does not, offer the single copy `cp "${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh" .githooks/lib/sysml-toolchain.sh && chmod +x .githooks/lib/sysml-toolchain.sh`. If `.githooks/` is absent, hand off to `@attention-regime`.

## Step 5: Install Offers

For each missing component of the preferred tool (and, on request, of a fallback), show the exact commands, ask for approval of that step, run only after a yes, and never chain steps into one approval. Flag every `[sudo]` step. Offer the route without sudo first where one exists. Order: Java first, then the tool. Syside is never installed by this skill: point at the vendor documentation for the CLI download and the `SYSIDE_LICENSE_KEY` variable, then re-probe.

**Java 21 or later (for `omg-pilot` only).** Detect the platform with `uname -s`, `uname -m`, and `ID` and `ID_LIKE` in `/etc/os-release`. A headless JRE suffices, because the plugin only runs a jar.

- Debian, Ubuntu, WSL: `[sudo] sudo apt install openjdk-21-jre-headless`. Alternative, Temurin through the Adoptium repository, four `[sudo]` steps: `[sudo] wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null`, `[sudo] echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list`, `[sudo] sudo apt update`, `[sudo] sudo apt install temurin-21-jdk`.
- Fedora, RHEL: `[sudo] sudo dnf install java-21-openjdk-headless`, or `temurin-21-jdk` with the Adoptium repository.
- macOS: `brew install --cask temurin@21`.
- Windows (native): `winget install -e --id EclipseAdoptium.Temurin.21.JDK`.
- Without sudo: a Temurin 21 archive from adoptium.net unpacked under `~/.local/share/java/<dir>`, with `export JAVA_HOME=~/.local/share/java/<dir>` in the shell profile. No archive URL is pinned here, so say the engineer picks the archive on the Adoptium page. The library honours `JAVA_HOME` and `VSE_JAVA`.

**OMG SysML v2 Pilot Implementation, release 2026-07, user-level, no sudo.**

```bash
mkdir -p ~/.local/share/sysml-pilot
ZIP=~/.local/share/sysml-pilot/jupyter-sysml-kernel-0.61.0.zip
curl -fsSL -o "$ZIP" \
  https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/releases/download/2026-07/jupyter-sysml-kernel-0.61.0.zip
if echo "3d310efb8a5332b11ec2441697d40ae10e7e04cfb8c8d121c198ffba38229ada  $ZIP" | sha256sum -c -; then
  unzip -q -o "$ZIP" -d ~/.local/share/sysml-pilot && rm -f "$ZIP"
else
  rm -f "$ZIP"
  echo "checksum failed or download missing, nothing extracted"
  false
fi
```

A failed checksum stops the step with a non-zero status: the download is deleted and nothing is extracted. A failure of `unzip` itself leaves the verified download in place for the `python3 -m zipfile` route below.

The release publishes no checksum file, so the value above was computed from the 126,125,572-byte artefact and recorded in the tooling wiki page. On macOS use `shasum -a 256 -c -` in place of `sha256sum -c -`. Without `unzip`, `python3 -m zipfile -e <zip> ~/.local/share/sysml-pilot`. The bundled `install.py` is the Jupyter kernel installer and is not run. Another location is honoured through `VSE_SYSML_PILOT_HOME`.

**OpenSysML v0.6.0, user-level, no sudo.** Linux amd64:

```bash
DL="$(mktemp -d)"
curl -fsSL -o "$DL/opensysml-linux-amd64.tar.gz" \
  https://github.com/Open-MBEE/OpenSysML/releases/download/v0.6.0/opensysml-linux-amd64.tar.gz
echo "15d4a2d12a0adaadcbb1ed53946061a113c793e60a9e159b790936938323fc38  $DL/opensysml-linux-amd64.tar.gz" | sha256sum -c - \
  && mkdir -p ~/.local/bin && tar -xzf "$DL/opensysml-linux-amd64.tar.gz" -C ~/.local/bin sysml sysml-lsp
rm -rf "$DL"
```

As with the pilot, a failed checksum stops the step and nothing is extracted.

The other archives (`opensysml-linux-arm64.tar.gz`, `opensysml-darwin-amd64.tar.gz`, `opensysml-darwin-arm64.tar.gz`, `opensysml-windows-amd64.zip`) and their checksums are listed in the release's `SHA256SUMS.txt`. macOS alternative: `brew install Open-MBEE/tap/opensysml`. Go route: `go install github.com/Open-MBEE/OpenSysML/cmd/sysml@v0.6.0` and `go install github.com/Open-MBEE/OpenSysML/cmd/sysml-lsp@v0.6.0`, whose binaries land in `$(go env GOPATH)/bin`. Say that the directory holding `sysml` must be on the PATH that git hooks see, which for hooks started from a GUI editor may differ from the shell's.

## Step 6: Verify

After each install, run from the project root and record the output:

1. `${CLAUDE_PLUGIN_ROOT}/hooks/lib/sysml-toolchain.sh java` prints the resolved binary, whose first `-version` line shows a major of 21 or more.
2. `... detect <tool>` exits 0.
3. Write `package VseToolchainProbe { part def Probe; }` to a file under `mktemp -d` and run `... validate --tool <tool> <file>`: exit 0 with no output. Write a second file `package VseToolchainBroken { part def X { attribute x : NoSuchType; } }` and run it: exit 1 with at least one `error:` line naming `NoSuchType` (the pilot prints two, the unresolved type and the typing rule it breaks). Remove the directory.
4. `... status` names the preferred tool as available.
5. For `opensysml` also `sysml-lsp -version`.

Then show the detection table again.

## Step 7: Report

State what was recorded, what was installed, what the hooks will do at the next commit (name the `precommit_lint` disposition for the project profile), and the CI implication: the shipped workflow template reads the same key and installs the same tool on the runner.

## Judgment Calls

The pattern for every item: name the rule and its section, state the concrete risk, recommend the conforming path, proceed on the engineer's informed confirmation.

- **Switching away from Syside while `syside.toml` carries project lint settings.** Say that those settings stop applying, because neither the pilot nor OpenSysML reads the file, and that the reference implementation is stricter than the Syside rules the file relaxed.
- **Choosing `omg-pilot` on a machine without Java and declining the install.** Say that every commit will fall back to the next installed tool, or at `full` will be refused with `No SysML toolchain is available`, until Java is installed.
- **`sudo`.** Never run a `[sudo]` step without the explicit yes for that step. Offer the no-sudo route first when one exists.
- **A `sysml` on the PATH that is not OpenSysML.** The probe says so (`-version` did not print `sysml`). Ask before installing over it.
- **A `syside.toml` in a project that never chose Syside.** The scaffold copies it only for `syside` or when no toolchain was chosen, so its presence records an earlier choice or an earlier silence. Say so before removing it.

## Hand-offs

- **To `@attention-regime`** when `.githooks/` is not installed, so the library lands with the hook set.
- **To `@project-setup`** when there is no `.iso-config.yaml` and no `methodology/`, because the project is not scaffolded.
- **To `@sysml2-modelling`** for authoring and syntax questions once the toolchain runs.
- **To `@document-export`** for diagram and document rendering, which only Syside performs today.
- **To `@project-audit`** for a full health check after a switch.

## Outputs

After a successful run: `.iso-config.yaml` carries `sysml_toolchain`, the project `CLAUDE.md` managed block carries the Toolchain line, `docs/semp.md` and `docs/project-plan.md` record the tool where those files exist, `.lsp.json` matches the toolchain (or is absent for the pilot without OpenSysML), `.githooks/lib/sysml-toolchain.sh` exists when the hooks are installed, and the installed components are under `~/.local/share/sysml-pilot` or `~/.local/bin`, with the detection table as the record.

## Syside reference

The rest of this skill is toolchain-neutral. This section is the Syside
surface in detail, and it applies only when the recorded toolchain is
`syside`.

### Sensmetry Syside product lineup

| Workflow | Product | Licence |
| --- | --- | --- |
| Learning, lightweight editing | **Syside Editor: SysML v2 Essential** (VS Code extension) | Free |
| Model writing, diagrams, grid views | **Syside Pro Suite** (Modeler) | Paid |
| CI/CD validation, headless diagrams, scripting | **Syside Pro Suite** (Automator and the `syside` CLI) | Paid |
| The Pro Suite without a local installation | **Syside Cloud** | Paid |
| Safety and security analysis (ISO 26262, ISO/SAE 21434, FMEA) | **Syside Derisker** | Beta |

**Syside Editor**: syntax highlighting, validation, auto-completion,
go-to-definition for .sysml and .kerml files.

**Syside Pro Suite**: everything the Editor provides plus synchronised
diagram visualisation and editable grid views (Modeler), the `syside`
command-line tool for validation, formatting, and diagram generation,
and the Automator, a Python 3.12+ library for programmatic model access,
querying, expression evaluation, requirements import and export, report
generation, and custom automation. Install the Automator with
`pip install syside`. One licence key covers the whole suite. You MUST
disable the Editor extension when the Modeler is active, to avoid
conflicts.

Additionally:
- **Sysand**: open-source SysML v2 package manager for reusable
  libraries. Read `pages/tooling/syside-sysand-package-management.md`.

Reference release: 0.10.3 (23 July 2026). Syside is pre-v1.0, so pin the
version a project depends on. Read
`pages/tooling/syside-tooling-overview.md` for the lineup, the roadmap,
and the breaking-change window.

### Syside CLI Commands

The CLI is the primary tool for terminal-based model operations. All commands
operate on the current directory recursively unless paths are specified.

**Prerequisites:** a valid Modeler licence (`SYSIDE_LICENSE_KEY`). Java is
a prerequisite of the OMG pilot, not of Syside, see `tooling-java-runtime`.
Set the licence via:
```bash
export SYSIDE_LICENSE_KEY="your-licence-key"
```

#### Validate Models

```bash
# Validate all models in the current directory
syside check

# Validate specific files
syside check model/system-requirements.sysml model/verification.sysml

# Fail on warnings (recommended for CI/CD)
syside check --warnings-as-errors

# Show statistics and timing
syside check --stats --time

# Exclude draft files
syside check --exclude "*.draft.sysml"
```

Exit codes for `syside check`: 0 valid, non-zero findings, and 2 with
`License check failed:` on an expired licence. The pilot always exits 0
and its verdict is parsed from standard output, and OpenSysML exits 0, 1
or 2, see the tooling pages.

Output format for errors:
```
model/system-requirements.sysml:12:5: error (CODE): message
```

#### Format Models

```bash
# Format all models in place
syside format

# Check formatting without modifying (for CI/CD and pre-commit)
syside format --check

# Custom line width
syside format --line-width 120

# Use tabs with 2-space width
syside format --tabs --tab-width 2
```

Exit codes for `--check` mode: 0 = properly formatted, 1 = needs reformatting,
2 = syntax errors.

#### Generate Diagrams (Syside only, Labs feature)

The `viz` commands shipped as a Labs feature with a stated availability
window to 2026-06-01. Confirm in the 0.10.x release notes that they are
still available before planning a workflow on them.

**Element diagrams** (by qualified name, no view definition needed):

```bash
# Generate SVG of a specific element
syside viz element "SmartSensor::SensorSystem" model/ --output-file build/sensor-system.svg

# PNG with depth control and zoom
syside viz element "SmartSensor::SensorSystem" model/ --depth=2 --zoom-level 3.0 --output-file build/sensor-system.png

# Full tree rendering
syside viz element "SmartSensor::SensorSystem" model/ --depth=-1 --rendering tree --output-file build/sensor-tree.svg
```

**View-based diagrams** (from SysML v2 view definitions in the model):

```bash
# Render all views to output directory
syside viz view model/ --output-dir build/diagrams

# Render a specific view
syside viz view model/ --qualified-name "Views::SystemOverview" --output-dir build/diagrams
```

Output formats: `.svg`, `.png`, `.pdf` (inferred from file extension).

**Headless Linux** (CI/CD, WSL without display): prefix with `xvfb-run -a`:

```bash
xvfb-run -a syside viz element "SmartSensor::SensorSystem" model/ --output-file build/sensor.svg
```

### Configuration

Create `syside.toml` in the project root. The `@project-setup` skill generates
this from the template at `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml`.

Key sections:

```toml
# Exclude generated files
exclude = ["build/**", "*.draft.sysml"]

[format]
line-width = 100       # Column limit for wrapping
tab-width = 4          # Spaces per indent
tabs = false           # Spaces, not tabs
markdown = true        # Treat comments as Markdown
empty-brackets = "braces"  # Use {} not ; for empty blocks

[lint]
standard-library-package = "warning"

[lsp]
completion-limit = 256
edit = "project"
```

See `${CLAUDE_PLUGIN_ROOT}/templates/common/syside.toml` for the full annotated
configuration.

### Terminal Workflows

**Nanocycle verification** (20-60 minute loops during model editing):

```bash
# Quick check after editing a model file
syside check model/system-requirements.sysml

# Format the file you just edited
syside format model/system-requirements.sysml
```

**Pre-commit validation** (before committing model changes):

```bash
# Run both checks
syside check --warnings-as-errors && syside format --check
```

**Documentation generation** (at iteration-boundary closure or at macrocycle delivery):

```bash
mkdir -p build/diagrams
syside viz view model/ --output-dir build/diagrams
# On headless Linux:
xvfb-run -a syside viz view model/ --output-dir build/diagrams
```

### Syside Automator Python API

The Automator provides programmatic access to SysML v2 models from Python.
Use it for model queries, expression evaluation, requirements import/export,
report generation, and custom validation scripts.

**Prerequisites:** Python 3.12+, valid licence (same key as Modeler).

```bash
pip install syside
export SYSIDE_LICENSE_KEY="your-licence-key"
python -c "import syside; print(syside.__version__)"
```

#### Loading and Querying Models

```python
import syside

# Load model files
model, diagnostics = syside.load_model(
    paths=syside.collect_files_recursively("model/")
)
assert not diagnostics.contains_errors(warnings_as_errors=True)

# Query all requirements
for req in model.nodes(syside.RequirementDefinition):
    print(req.declared_name, req.qualified_name)

# Query all parts (user-defined only, excluding standard library)
for part in model.nodes(syside.PartUsage):
    if part.document.document_tier is syside.DocumentTier.Project:
        print(part.name)

# Extract documentation
for doc in model.nodes(syside.Documentation):
    if doc.owner and doc.owner.qualified_name:
        print(f"{doc.owner.qualified_name}: {doc.body}")
```

#### Evaluating Expressions and Constraints

```python
STDLIB = syside.Environment.get_default().lib
compiler = syside.Compiler()

# Evaluate an attribute value with unit conversion
for attr in model.nodes(syside.AttributeUsage):
    if attr.name == "TotalMass":
        value, report = compiler.evaluate_feature(
            feature=attr,
            scope=attr.owner,
            stdlib=STDLIB,
            experimental_quantities=True,
        )
        if not report.fatal:
            print(f"Total mass: {value}")
```

#### Interactive Exploration

Launch an interactive REPL to explore a model without writing scripts:

```bash
python -m syside interactive model/system-requirements.sysml
```

```python
>>> len(list(model.nodes(syside.RequirementDefinition)))
12
>>> for req in model.nodes(syside.RequirementDefinition):
...     print(req.declared_name)
```

#### Key Automator Workflows

| Workflow | Description | Skill |
| --- | --- | --- |
| Requirements to Excel | Export requirements as spreadsheet for acquirer review | `@needs-and-requirements` |
| Requirements from Excel | Import requirements from spreadsheet into SysML | `@needs-and-requirements` |
| Semantic trace checking | Programmatic verify/satisfy link analysis | `@traceability-guard` |
| Value rollup | Mass, power, cost budgets with unit conversion | `@architecture-design` |
| Part hierarchy extraction | Walk ownership tree, filter by type | `@architecture-design` |
| Variant analysis | Extract and compare configurations | `@architecture-design` |
| Report generation | Jinja2 templates with model data, traceability matrices | `@document-export` |
| State machine simulation | Simulate SysML state machines in Python | `@verification-validation` |
| Constraint checking | Evaluate requirement bounds against model values | `@verification-validation` |

For full API details, read the `syside-tooling-overview`, `syside-core-api`,
`syside-expression-evaluation`, `syside-model-modification`, and
`syside-vse-workflows` atomic pages under `wiki/pages/tooling/`.

## Knowledge base

The plugin wiki root is `${CLAUDE_SKILL_DIR}/../../wiki`. Read pages on
demand with the Read tool. Do not bulk-load. Pick the pages the task
needs. For anything not listed, consult `INDEX.md` at the wiki root, or
search: `grep -ril "<term>" <wiki-root>/pages`.

<!-- wiki-routing:begin -->
| Page | Path | Read when |
|---|---|---|
| Syside Automator Core API | pages/tooling/syside-core-api.md | Loading, querying, and traversing SysML 2.0 models from the Syside Automator Python library |
| Syside Expression Evaluation and Compiler | pages/tooling/syside-expression-evaluation.md | Evaluating SysML expressions, feature values with units, requirements, and metadata filters |
| Syside Model Modification and Element Reference | pages/tooling/syside-model-modification.md | Adding, removing, and exporting model elements through the Syside API, with an element type reference |
| Syside Project Configuration: syside.toml and .lsp.json | pages/tooling/syside-project-configuration.md | Three-level syside.toml discovery, merge semantics, the format, lsp, lint and telemetry sections, and .lsp.json |
| Sysand Package Management for SysML v2 | pages/tooling/syside-sysand-package-management.md | Sysand manifests, the lock file, KPAR packaging, the public index, and CI publishing for SysML v2 |
| Syside Tooling Overview and Installation | pages/tooling/syside-tooling-overview.md | Choosing between Syside Editor, Pro Suite, Cloud, and Derisker, plus installation and licence setup |
| Syside VSE Workflows and Report Generation | pages/tooling/syside-vse-workflows.md | Syside workflows for requirement round-trips, grid views, hierarchy walks, trace checks, CI, and reports |
| Java 21 runtime for the OMG pilot | pages/tooling/tooling-java-runtime.md | Installing a Java 21 runtime per platform for the OMG pilot, JRE versus JDK, JAVA_HOME, and the version check |
| OMG SysML v2 Pilot Implementation: installation and batch validation | pages/tooling/tooling-omg-pilot-batch-validation.md | Installing the OMG SysML v2 Pilot Implementation and validating a model through SysMLInteractive in batch |
| OpenSysML: installation, CLI validation, and language server | pages/tooling/tooling-opensysml-cli.md | Installing OpenSysML, validating with sysml -validate, its exit codes, and wiring sysml-lsp as the editor server |
| SysML v2 rules the reference implementations enforce | pages/tooling/tooling-reference-implementation-rules.md | SysML v2 forms the pilot and OpenSysML refuse or accept, from subject ordering to derivation and enum literals |
| Choosing a SysML v2 toolchain: Syside, OMG pilot, OpenSysML | pages/tooling/tooling-sysml-toolchain-choice.md | Choosing between Syside, the OMG pilot, and OpenSysML, their licences, capabilities, and the fallback order |
| Validator selection and fallback in the pre-commit lint gate | pages/tooling/tooling-validator-fallback-process.md | How the pre-commit lint gate picks a SysML v2 validator, falls back with a notice, and reports findings |
<!-- wiki-routing:end -->
