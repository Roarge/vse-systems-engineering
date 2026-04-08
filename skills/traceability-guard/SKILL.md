---
name: traceability-guard
description: Check SysML requirement traceability (satisfy/verify links). Use when checking trace gaps, generating traceability matrices, at iteration-boundary closure, or before a macrocycle release tag.
user-invocable: true
---

# Traceability Guard

If the VSE lens has not been set in this session, invoke `vse-companion-overview` first, then continue.

You are an environmental guard that enforces machine-readable traceability
(R3). You check trace completeness, detect gaps, and flag them as iteration
boundary closure debt or (at the macrocycle) as release blockers. You can
be invoked on demand or called automatically by `@iteration-orchestrator`
at iteration-boundary closure and at the macrocycle release gate.

## When This Skill Triggers

- The user asks to check traceability
- The `@iteration-orchestrator` invokes you at iteration-boundary closure
  or at macrocycle release tagging
- The user asks to generate a traceability matrix
- The user has modified requirements or verification cases

## Trace Rules

### Rule 1: Upward Traceability
Every system requirement MUST trace to at least one stakeholder need via a
`satisfy` link.

### Rule 2: Downward Traceability
Every system requirement MUST trace to at least one verification case via a
`verify` link.

### Rule 2a: Element Traceability
**Rule 2a (Element Traceability):** Every system element requirement MUST trace
upward to at least one system requirement via a `satisfy` link. Every system
element requirement MUST trace downward to at least one verification case via
a `verify` link.

### Rule 3: Validation Coverage
Every stakeholder need MUST have at least one validation case.

### Rule 4: No Orphans
No verification case should exist without a `verify`
link to a requirement. No system requirement should exist without a `satisfy`
link to a stakeholder need. No system element requirement should exist without
a `satisfy` link to a system requirement.

### Rule 5: Bidirectional Consistency
If requirement A satisfies need B, then need B must be traceable to requirement
A. The model must be consistent in both directions.

## Check Procedure

### Step 1: Find All Model Files

```
Glob for: models/**/*.sysml
```

### Step 2: Extract Requirements

Search for `requirement def` declarations. For each, record:
- The requirement ID (from the `id` attribute)
- Whether it has a `satisfy` link (upward trace)
- Whether any verification case has a `verify` link to it (downward trace)

### Step 3: Extract Stakeholder Needs

Search for stakeholder need declarations (requirements in the StakeholderNeeds
package). For each, record:
- Whether at least one system requirement satisfies it
- Whether at least one validation case verifies it

### Step 3a: Extract element requirements

Search for `requirement def` entries with the `ELE-` prefix or within an
`ElementRequirements` package. For each:
- Check that it has a `satisfy` link to a system requirement (Rule 2a upward)
- Check that at least one verification case has a `verify` link to it (Rule 2a downward)

### Step 4: Extract Verification Cases

Search for `verification def` declarations. For each, record:
- The verification ID
- Whether it has a `verify` link to a requirement

### Step 4a: Cross-check bidirectional consistency (Rule 5)

For each `satisfy` link found in a requirement:
- Verify the target stakeholder need or system requirement exists in the model
- Verify that the target entity is reachable (not in a missing file)

For each `verify` link found in a verification case:
- Verify the target requirement exists in the model

Report any broken links (referencing entities that do not exist) as Rule 5
violations.

### Step 5: Generate Gap Report

Present results as a table:

```
TRACEABILITY CHECK RESULTS
==========================
Requirements checked: [n]
  With upward trace (satisfy):    [n] / [total]
  With downward trace (verify):   [n] / [total]

Stakeholder needs checked: [n]
  With system requirement:        [n] / [total]
  With validation case:           [n] / [total]

Verification cases checked: [n]
  With requirement link:          [n] / [total]

GAPS FOUND: [n]
  [list each gap with: item ID, missing direction, suggested fix]
```

| Gap Type | Rule |
|----------|------|
| Element requirement without satisfy link to system requirement | Rule 2a |
| Element requirement without verification case | Rule 2a |
| Verification case without verify link to element or system requirement | Rule 4 |

### Step 6: Block or Allow

- **If no gaps**: report "Traceability check passed. All traces complete."
- **If gaps exist**: report each gap. If the check was invoked at
  iteration-boundary closure, record the gaps as iteration-boundary
  closure debt and let the engineer decide whether to close the iteration
  with debt carried forward or to rework inside the current iteration. If
  the check was invoked at the macrocycle release gate, state
  "Traceability check FAILED. Macrocycle release blocked until gaps are
  resolved."

## Traceability Matrix Generation

### Dispatch to `vse-traceability-matrix-builder`

When asked to generate a traceability matrix across the full model
tree, dispatch to the `vse-traceability-matrix-builder` subagent
rather than walking the files inline. The subagent runs in an isolated
context, so the parent skill never has to load every model file into
its own window.

**When to dispatch.** Whenever matrix generation is requested across
more than a handful of model files, or whenever the parent skill is
already carrying significant state from earlier in the session.

**What to pass.** The model directory path (default `models/`), an
optional scope filter listing the identifier prefixes to include
(`STK-`, `REQ-`, `ELE-`, `VER-`, `VAL-`), and the trace rules to
apply. Default to all five rules from the section above.

**How to present the result.** The subagent returns a markdown matrix,
a gap report keyed by rule, and a bidirectional consistency check.
Present the matrix and gap report verbatim to the engineer. The
suggestions are draft fixes, not commands. The engineer decides which
gaps to act on, and the parent skill routes any agreed fixes back to
`@needs-and-requirements`, `@architecture-design`, or
`@verification-validation` as appropriate.

When the model is small or the engineer wants a quick spot check, the
inline table format below remains available as a fallback.

When asked to generate a traceability matrix, produce a table:

| Stakeholder Need | System Requirement | Element Requirement | Verification Case | Status |
|-----------------|-------------------|--------------------|--------------------|--------|
| STK-001 | REQ-001, REQ-002 | ELE-001 | VER-001, VER-002 | Complete |
| STK-002 | REQ-003 | (missing) | (missing) | Gap |
| STK-003 | (missing) | -- | -- | Gap |

## Fix Suggestions

For each gap, suggest the specific fix:

| Gap Type | Suggestion |
|----------|-----------|
| Requirement without satisfy | "Add `satisfy requirement [need-id];` to this requirement" |
| Requirement without verify | "Create a verification case with `verify requirement [req-id];`" |
| Need without requirement | "Derive a system requirement from this stakeholder need" |
| Need without validation | "Create a validation case for this stakeholder need" |
| Orphan verification case | "Add a `verify` link or remove this unused case" |

## Automator-Enhanced Checking

When the Syside Automator Python library is available (`pip install syside`),
use it for **semantic trace checking** instead of grep-based text matching.
This provides accurate relationship traversal, broken link detection, and
documentation extraction.

### Check Automator Availability

```bash
python -c "import syside; print(syside.__version__)"
```

If Automator is not available, fall back to the grep-based procedure above.

### Semantic Trace Check Script

Use this script template to perform programmatic trace analysis:

```python
import syside
import sys

def check_traceability(model_dir: str = "models/") -> list[str]:
    """Check trace completeness across all SysML models."""
    paths = syside.collect_files_recursively(model_dir)
    model, diagnostics = syside.try_load_model(paths=paths)

    if diagnostics.contains_errors():
        print("Model has syntax errors. Fix these before trace checking.")
        print(syside.format_diagnostics(diagnostics))
        return []

    gaps = []
    req_count = 0
    ver_count = 0
    val_count = 0
    satisfy_count = 0
    verify_count = 0

    # Check all requirement definitions
    for req in model.nodes(syside.RequirementDefinition):
        if req.document.document_tier is not syside.DocumentTier.Project:
            continue
        req_count += 1
        has_satisfy = False
        has_verify = False

        for child in req.owned_elements.collect():
            # Check for satisfy relationships
            if child.try_cast(syside.RequirementUsage) is not None:
                has_satisfy = True
                satisfy_count += 1
            # Check for verification case references
            if child.try_cast(syside.VerificationCaseUsage) is not None:
                has_verify = True
                verify_count += 1

        name = req.declared_name or req.name or "(unnamed)"
        if not has_satisfy:
            gaps.append(f"Rule 1: {name} has no satisfy link (upward trace)")
        if not has_verify:
            gaps.append(f"Rule 2: {name} has no verify link (downward trace)")

    # Check all verification case definitions
    for ver in model.nodes(syside.VerificationCaseDefinition):
        if ver.document.document_tier is not syside.DocumentTier.Project:
            continue
        ver_count += 1
        has_verify_link = False
        for child in ver.owned_elements.collect():
            if child.try_cast(syside.RequirementUsage) is not None:
                has_verify_link = True
        name = ver.declared_name or ver.name or "(unnamed)"
        if not has_verify_link:
            gaps.append(f"Rule 4: {name} is an orphan verification case")

    # Report
    print(f"Requirements checked: {req_count}")
    print(f"  With satisfy links: {satisfy_count}")
    print(f"Verification cases checked: {ver_count}")
    print(f"GAPS FOUND: {len(gaps)}")
    for gap in gaps:
        print(f"  {gap}")

    return gaps

if __name__ == "__main__":
    model_dir = sys.argv[1] if len(sys.argv) > 1 else "models/"
    gaps = check_traceability(model_dir)
    sys.exit(1 if gaps else 0)
```

### Advantages Over Grep-Based Checking

| Aspect | Grep-based | Automator-based |
| --- | --- | --- |
| Accuracy | Text pattern matching, false positives possible | Semantic model traversal, exact relationship analysis |
| Broken link detection | Cannot detect references to non-existent elements | Diagnostics report invalid references |
| Documentation extraction | Limited to raw text | Structured access to doc bodies for enriched reports |
| Cross-package resolution | Requires manual import tracking | Automatic resolution across packages |
| Requirement attributes | Must parse attribute strings | Direct access to typed attribute values |

### Enriched Gap Report

When Automator is available, the gap report can include requirement
documentation for context:

```python
for req in model.nodes(syside.RequirementDefinition):
    if req.document.document_tier is not syside.DocumentTier.Project:
        continue
    for doc in req.documentation.collect():
        # Include requirement text in gap report for context
        print(f"  {req.declared_name}: {doc.body[:80]}...")
```

## Integration with Other Skills

- `@iteration-orchestrator` calls this skill at every iteration-boundary closure and at the macrocycle release gate
- `@needs-and-requirements` calls this skill after Step 7 (establish traceability)
- `@verification-validation` calls this skill after Step 4 (trace check)
- `@architecture-design` calls this skill after Step 6 (verify architecture)
- The `pre-commit-traceability` hook performs a lightweight version of this
  check on staged .sysml files

## SysML 2.0 Authoring Routing

When a gap has to be closed inside the SysML 2.0 model, route to the
following siblings:

| Topic | Route to |
| --- | --- |
| Satisfy and verify link authoring | `@sysml2-modelling` (router) plus `@sysml2-cases` for case bodies |
| Allocation traces | `@sysml2-allocations` |
| Risk-to-requirement and risk-to-verification advisory traces | `@sysml2-metadata` (RiskInfo) plus `@sysml2-model-structure` (`{{sc}}_Risks`) |
| Variant configuration traces (orphan variations or missing bindings) | `@sysml2-variants` for syntax plus `@sysml2-model-structure` (`{{sc}}_Configurations`) |
| Model-level CM traces | `@sysml2-metadata` (ConfigItem, Baseline) plus `@sysml2-model-structure` (`{{sc}}_CM`) |

## Advisory Orphan Surfaces

In addition to the satisfy/verify backbone, surface these advisory
orphan categories in the trace matrix. They do not block at
iteration-boundary closure but they are the debt that has to be
cleared before the macrocycle release gate:

- **Orphan risks.** Item defs in `{{sc}}_Risks` with no `mitigatedBy`
  reference and no closed status. Every open high-severity risk must
  point at a mitigation (requirement, verification case, or
  architecture element).
- **Orphan mitigations.** Requirements or verification cases that
  claim to mitigate a risk that does not exist in the register.
- **Orphan variations.** Variation definitions declared in the core
  (usually inside `{{sc}}_ArchDesign` per Ch 35) but never bound in
  any configuration inside `{{sc}}_Configurations`.
- **Orphan configurations.** Specialised owners declared in
  `{{sc}}_Configurations` that are missing bindings for one or more
  of the variations in the core. A configuration must redefine every
  variation it cares about.
- **Orphan ConfigItems.** Elements tagged with `@ConfigItem` whose
  `baselineId` does not resolve to a `Baseline` item def anywhere in
  `{{sc}}_CM`. Cross-reference Project Plan Section 9 Configuration
  Management Strategy for the governance authority on when a baseline
  is taken.
- **Baseline scope integrity.** Every element named in a baseline's
  `scope` reference list must exist and must be in the `Baselined`
  state. A scope entry pointing at a missing or `Draft` element is a
  baseline-scope gap.

## Red Flags

WARN the engineer if:
- Trace gaps are increasing over time (more gaps than last check)
- Requirements are being added without corresponding verification cases
- Verification cases are being removed without removing the requirement
- The Traceability Matrix has not been updated after model changes
- Orphan risks, orphan mitigations, orphan variations, or orphan
  ConfigItems appear in the advisory surfaces above
