---
title: "AMBSE Interface Specification and Handoff to Downstream Engineering"
slug: ambse-interfaces-and-handoff
type: process
layer: ambse
tags: [interfaces, logical, physical, handoff, icd, iteration-boundary]
sources:
  - citation: "Douglass, B.P. (2016). Agile Systems Engineering. Chapters 7-8."
    raw: Douglass_2016_Agile_Systems_Engineering.pdf
  - citation: "Douglass, B.P. (2021). Agile MBSE Cookbook. Chapter 5 and p. 61 (handoff workflow)."
    raw: Douglass_2021_Agile_MBSE_Cookbook.pdf
related:
  - ambse-architectural-design
  - ambse-architecture-vv-and-iso29110
  - sysml2-syntax-structure
  - sysml2-allocations-overview
confidence: high
created: 2026-05-04
updated: 2026-05-04
bundled_by: [architecture-design]
---

# AMBSE Interface Specification and Handoff to Downstream Engineering

Interfaces are the most critical architectural artefact for
system integration. Douglass emphasises that interface defects
are among the most expensive to fix because they affect
multiple subsystems. For the architectural design that
generates these interfaces see [[ambse-architectural-design]].

## Logical vs physical interfaces

During architectural design, interfaces are **logical**: they
specify the essential properties of data and control flows
without committing to a physical implementation. Logical
interfaces capture:

- Data type, range, accuracy, and units.
- Direction of flow (in, out, inout).
- Timing constraints (update rate, latency).
- Protocol semantics (request-response, publish-subscribe,
  streaming).

**Physical interfaces** (wire protocol, connector type, voltage
levels) are defined during the handoff to downstream
engineering.

## SysML 2.0 interface modelling

For the underlying SysML 2.0 syntax for ports, connections,
and interfaces, see [[sysml2-syntax-structure]]. For
allocations across architectural layers, see
[[sysml2-allocations-overview]].

```sysml
// Port definition with typed features
port def SensorDataPort {
    out item temperatureReading : TemperatureValue;
    out item pressureReading : PressureValue;
    attribute updateRate : Real = 10.0; // Hz
}

// Interface definition connecting two subsystems
interface def SensingToProcessing {
    end port supplier : SensorDataPort;
    end port receiver : ~SensorDataPort;
}

// Interface usage
interface sensingLink : SensingToProcessing
    connect sensing.sensorDataOut to processing.sensorDataIn;
```

## VSE interface guidance

- Define interfaces early and baseline them before downstream
  engineering begins.
- Interfaces are configuration-managed: changes require a
  Change Request.
- For each interface, document the owner (which subsystem team
  controls it).
- Test interface assumptions in the first iteration
  (integration risk reduction).

## Handoff to downstream engineering

The handoff is **not an event but a workflow** that transforms
system engineering data into the data needed by implementation
disciplines. This is a critical activity that is often done
poorly.

### Handoff workflow (two parallel flows)

**Shared model flow** (for data shared by two or more
subsystems):

1. Gather subsystem specification data (SRS, architecture,
   logical ICD, scenarios).
2. Create the shared model (interfaces, shared data
   definitions, shared resources).
3. Define physical interfaces (transform logical to physical
   specifications).

**Subsystem model flow** (repeated for each subsystem):

1. Create the subsystem model (import requirements from the
   system model).
2. Define interdisciplinary interfaces (software-electronic,
   electro-mechanical).
3. Allocate requirements to engineering disciplines.
4. Output: subsystem SRS, physical ICD, discipline-specific
   requirements.

### Handoff package contents

A complete handoff package for each subsystem includes:

| Artefact | Description |
|---|---|
| Subsystem requirements | Allocated and derived requirements |
| Interface specification | Physical ICD with protocols and data formats |
| Verification criteria | Test cases and acceptance criteria per requirement |
| Behavioural model | State machines or action sequences for subsystem use cases |
| Design constraints | Technology, environmental, and regulatory constraints |
| Rationale | Trade study results and architectural decisions |

### Handoff as iteration boundary

In hybrid AMBSE the handoff occurs at iteration boundaries:

- System engineers hand off iteration N to downstream engineers.
- System engineers proceed to specify iteration N+1.
- This creates pipeline parallelism even in small teams (the
  same person switches roles at the iteration boundary).

**Canonical handoff form**: a pull request against `main`. The
iteration's work lives on a `vse/iter-NN` feature branch, and
the merge of that branch via pull request **is** the handoff
event Douglass describes (Cookbook, p. 61). The PR diff is the
converted engineering data, the PR body summarises the
iteration mission and the trace status, and the PR review is
the formal handoff acceptance. CI gates run the trace check
and the phase-gate check before the PR can merge. See
[[story-branch-pr-workflow]] for the full mapping, branch
naming, and PR body template.

VSE guidance: do not over-formalise the handoff for small
teams. The pull request mechanism is intentionally lightweight,
and the same mechanism works for a single-developer self-review
and a five-person peer review. The key is that downstream
engineering has an unambiguous, baselined specification to
work from, and that the iteration boundary is recorded in git
history rather than in chat.

## See also

- [[ambse-architectural-design]] for the upstream design
  workflow.
- [[ambse-architecture-vv-and-iso29110]] for V&V and the ISO
  29110 mapping.
- [[story-branch-pr-workflow]] for the canonical handoff form
  (PR against main).
- [[sysml2-syntax-structure]] for port and interface syntax.
- [[sysml2-allocations-overview]] for cross-layer allocations.
