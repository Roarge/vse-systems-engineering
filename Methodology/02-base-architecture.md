# 2. Base Architecture

## 2.1 Purpose

The Base Architecture is the set of architectural and technical
decisions that **pre-exist the project and constrain its work from
outside it**. The methodology captures it as a reference, not as a
subject of specification.

Two corollaries follow, and both are load-bearing for §3 onward:

1. **The Base Architecture is exogenous constraint, not project
   specification.** The project does not own the decisions encoded in
   it. They are made by the parent organisation (product-line
   commitments, platform selections), by the customer (installed
   infrastructure, deployment environment), by parent products
   (subsystems inherited from a larger system), or by regulators
   (certifying authorities, mandated standards). The methodology
   requires the project to *acknowledge* and *reference* these
   decisions; it does not invite — and shall not be used to produce —
   project artefacts whose role is to *justify* them.

2. **Stories move forward from the Base Architecture.** The story
   register authored in §4–§7 captures what the project shall *add*
   on top of the Base Architecture. Forward-going stories are the
   methodology's required output.

   The user may additionally choose to author *context stories* —
   stories that record narrative around Base Architecture decisions,
   for purposes such as onboarding documentation, audit trail, or
   organisational memory. Context stories are optional: the
   methodology neither requires nor forbids them when added by
   deliberate human choice.

   What is forbidden is **reverse-engineering**: synthesising
   stakeholders, concerns, or stories whose role is to fabricate
   post-hoc justification for an existing Base Architecture decision.
   AI agents authoring or completing the story register on behalf of
   the user shall not synthesise context stories and shall not
   reverse-engineer justifications. The default agent posture is
   forward-going work; context stories may be authored only on
   explicit human request, with explicit confirmation of intent.

   Concrete distinction: a stakeholder fabricated as "AC5000 platform
   vendor" with a story "I want my platform to support 64 channels
   so that I can sell more units" is reverse-engineered — the
   vendor's stakeholder needs belong in the vendor's project
   register, not this one. By contrast, a user may legitimately add a
   context story such as "operations selected the AC5000 in 2019 to
   consolidate the existing fleet" as deliberate organisational
   memory, distinguishable as context-only and not part of the
   forward-going register.

The Base Architecture supplies the abstraction level at which
stakeholder requirements are written, fixes the technology choices the
project must build on, and exposes the `part def` instances that
downstream stories reference as their `subject`.

The concept is adopted from SYSMOD §5.7 (Weilkiens, 2020). Adaptations
from the source are:

- The Base Architecture is modelled in SysML v2 as a `library package`
  containing `part def` instances and immutable constraints, rather
  than in tool-specific stereotypes.
- The project's system either *specialises* (`:>`) the Base
  Architecture or is *allocated* to it via SysML v2 allocation
  relationships (spec §7.15), depending on coupling.
- The forward-going specification rule (corollary 2 above) is made
  explicit and CI-checkable per §2.6 rule 5.

## 2.2 Definition

The Base Architecture is a SysML v2 `library package` (spec §7.4 — model
libraries) declaring:

- one or more `part def` representing the architectural givens
  (platforms, infrastructure, devices, protocols);
- attributes and value properties on those part defs that the project
  cannot redefine;
- `require constraint` clauses capturing immutable architectural
  constraints;
- enumerations and item definitions that downstream packages depend on
  for type compatibility.

A Base Architecture part def is *not* an instantiated system — it is a
type that the project's system inherits from or is bound to. Multiple
projects within an organisation may share the same Base Architecture.

## 2.3 Workflow

**Inputs:** organisational product-line assets, customer infrastructure,
regulatory mandates, parent-product specifications.

**Outputs:** a `library package` exposing the architectural givens, plus
the relationship between the project's system and that library.

### 2.3.1 Identify the architectural givens

Enumerate the elements that the project must build on rather than
choose. Common categories:

- **Platforms** — hardware controllers, OS distributions, runtime
  environments.
- **Protocols and standards** — communication protocols, data formats,
  industry standards the project must conform to.
- **Reused subsystems** — components inherited from a parent product.
- **Regulatory frameworks** — certifying authorities, applicable
  standards, mandated processes.

Each identified element becomes a candidate `part def` in §2.3.2.

### 2.3.2 Model the architectural givens as part definitions

For each architectural given, declare a `part def` in a `library
package`. Capture:

- Attributes that describe the given (model number, version, capacity).
- Value properties that other parts may reference (clock frequency,
  voltage, throughput).
- Ports that interact with the rest of the system (spec §7.13).
- Constraints that the project cannot violate.

```sysml
library package <BA> Aiwell_BaseArchitecture {

    part def AC5000_Platform {
        attribute modelRevision : String;
        attribute firmwareVersion : String;
        attribute maxIOChannels : Natural = 64;

        port modbusTCP : ModbusTCPPort;
        port digitalIO : DigitalIOPort[16];

        require constraint maxChannelsConstraint {
            doc /* Configured I/O channel count shall not exceed
                   maxIOChannels. */
        }
    }

    part def CommunicationProtocol abstract;
    part def ModbusTCP :> CommunicationProtocol;
    part def OPCUA    :> CommunicationProtocol;
}
```

Constraints expressed here are *immutable* in the sense that the
project shall not redefine them. They may be inherited by specialising
parts but not weakened.

### 2.3.3 Establish the relationship to the project system

The project's system part def is related to the Base Architecture in
one of two ways:

**Specialisation** — when the project produces an instance of the
platform (e.g., a configured AC5000-based device):

```sysml
part def Aiwell_OnlineSentral :> Aiwell_BaseArchitecture::AC5000_Platform {
    attribute :>> modelRevision = "OS-2026-A";
    attribute :>> firmwareVersion = "3.4.1";
    /* … */
}
```

**Allocation** — when the project's system runs *on* the platform
without specialising it (the platform is a host, not a parent type):

```sysml
part def Aiwell_OnlineSentral { /* … */ }

allocation hostsApplication
    allocate Aiwell_OnlineSentral
    to      Aiwell_BaseArchitecture::AC5000_Platform;
```

Specialisation is preferred when the project's system inherits structure
and constraints from the platform. Allocation is preferred when the
project's system is logically independent but physically deployed on
the platform.

### 2.3.4 Publish the package

The Base Architecture package is imported by §3 (System Context), §4
(Stakeholder Requirements), and downstream sections as needed. Stories'
`subject` clauses reference Base Architecture part defs (or
specialisations thereof).

## 2.4 Artefacts produced

- A `library package` containing the project's Base Architecture
  declarations.
- The coupling relationship between the project's system part def and
  the Base Architecture (specialisation or allocation).
- Project-determined README or rationale document explaining the
  organisational context of each given.

## 2.5 SysML v2 syntactic patterns

| Pattern | Form |
|---|---|
| Library package | `library package <BA> Project_BaseArchitecture { … }` |
| Architectural given | `part def Name { attribute … ; port … ; require constraint … }` |
| Specialisation | `part def ProjectSystem :> BasePart { … }` |
| Allocation | `allocation <name> allocate ProjectSystem to BasePart;` |
| Immutable constraint | `require constraint <name> { doc /* … */ }` |

## 2.6 Well-formedness rules

1. The Base Architecture shall reside in a `library package` and shall
   not import any package outside `library/`, `core/domain/`, or
   external libraries.
2. Every `require constraint` in the Base Architecture shall remain
   satisfied by every specialising part. CI-side validation shall flag
   a specialising part that overrides an inherited constraint with a
   weaker one.
3. The project's system part def shall have exactly one relationship
   to the Base Architecture: either specialisation or allocation, not
   both. (A system that genuinely is both — instance of one platform,
   running on another — shall make the structural relationship
   explicit by introducing intermediate part defs.)
4. Base Architecture changes shall be reviewed under elevated final-
   review criteria (§8.6.3), because they propagate to every story
   whose subject specialises a Base Architecture part def.
5. Forward-going stories — the methodology's required output — shall
   declare their `subject` as the project's system or one of its
   subsystems, typically a *specialisation* of a Base Architecture
   `part def` rather than the part def itself. Context stories (per
   §2.1 corollary 2) added by deliberate human choice may declare a
   Base Architecture part def as `subject`. CI shall emit an
   informational warning when a story's `subject` resolves to a part
   def declared in a `library package` of the Base Architecture, both
   to confirm intent and to mark the story as optional context rather
   than required output. The warning shall not block.
6. Concerns informed by Base Architecture limitations are legitimate
   — e.g., "the chosen platform's lack of feature X means the project
   must compensate by …" — and address what the project shall do
   given the constraint, with the project's system as their subject.
   Concerns whose subject is the Base Architecture itself are
   optional context-recording (CI warns, does not block).
7. **Agent-collaboration discipline.** AI agents authoring or
   modifying the story register, concern register, or related
   project artefacts shall not synthesise context stories and shall
   not reverse-engineer Base Architecture justifications. Such
   artefacts may be added only on explicit human request, with
   explicit confirmation of intent. The default agent posture is
   forward-going work. This rule is a methodology-level instruction
   to agents and is not enforced by CI; it is preserved through the
   `CLAUDE.md` (or equivalent) project memory file and through
   prompt-side reminders such as the `UserPromptSubmit` hook in
   `iso-29110-hooks-guide.md`.

## 2.7 Lifecycle

The Base Architecture is updated only by deliberate change events,
not on every iteration. Updates fall into three categories:

- **Discovery** — an architectural given that already exists in the
  project's environment was missed in the initial Base Architecture
  capture and is added. This is *acknowledgement* work: making the
  reference faithful to a reality the project does not own.
- **Refinement** — a given was modelled coarsely and is now detailed.
  Same posture: refining the reference, not specifying behaviour.
- **Replacement** — the organisation has migrated to a new platform.
  Externally driven; the project must follow.

In none of the three categories does the project author *stories* to
drive the update. Base Architecture changes are made directly to the
`library package` and reviewed under elevated final-review criteria
(§8.6.3). Stories may then need to be revised because their referenced
parts have changed — that is downstream propagation, not the cause of
the update.

Updates of the third kind require a coordinated migration of every
specialising part across the project; they shall be planned as their
own work item rather than executed inside an unrelated story branch
(§8.4.3).

## 2.8 Out of scope

- Detailed design of the Base Architecture parts beyond what the
  project needs to bind to. The Base Architecture is a *reference*; the
  parts referenced may have their own internal models elsewhere.
- Cross-project governance of shared Base Architecture libraries.
  Where multiple projects share a library, the governance of that
  library is project-set-determined, not specified here.

---

*End of Section 2.*
