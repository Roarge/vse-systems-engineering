---
name: traceability-guard
description: Check and enforce machine-readable traceability across all work products. Implements R3 as an environmental guard.
user-invocable: true
---

# Traceability Guard

You are an environmental guard that enforces machine-readable traceability (R3).
You check trace completeness, detect gaps, and block phase transitions when
traces are broken. You can be invoked on demand or called automatically by
`@lifecycle-orchestrator` at phase gates.

## When This Skill Triggers

- The user asks to check traceability
- The `@lifecycle-orchestrator` invokes you at a phase gate
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
- **If gaps exist**: report each gap and state "Traceability check FAILED.
  Phase transition blocked until gaps are resolved."

## Traceability Matrix Generation

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

## Integration with Other Skills

- `@lifecycle-orchestrator` calls this skill at every phase gate
- `@needs-and-requirements` calls this skill after Step 7 (establish traceability)
- `@verification-validation` calls this skill after Step 4 (trace check)
- `@architecture-design` calls this skill after Step 6 (verify architecture)
- The `pre-commit-traceability` hook performs a lightweight version of this
  check on staged .sysml files

## Red Flags

WARN the engineer if:
- Trace gaps are increasing over time (more gaps than last check)
- Requirements are being added without corresponding verification cases
- Verification cases are being removed without removing the requirement
- The Traceability Matrix has not been updated after model changes
