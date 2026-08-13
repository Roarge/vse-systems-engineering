---
title: "SYSMOD test modelling: Model Test Cases and the Test Architecture"
slug: sysmod-test-modelling
type: concept
layer: sysmod
summary: SYSMOD's verdict-returning test behaviours, the Model Test Case, and the Test Architecture as a system in its own right
tags: [sysmod, test-cases, model-test-case, test-architecture, verdict, system-under-test, verification, validation]
sources:
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §4.16 and §4.22 (Specify Test Cases, Model the Test Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §5.16 and §5.24 (Test Cases, Test Architecture)"
    raw: sysmod.pdf
  - citation: "Weilkiens, T. (2020). SYSMOD - The Systems Modeling Toolbox, 3rd edition. MBSE4U. §7.14 and §7.19 (How to specify Test Cases and model the Test Architecture)"
    raw: sysmod.pdf
related:
  - vv-planning
  - vv-definitions
  - vv-methods
  - vv-reporting-and-vse-guidance
  - sysmod-toolbox-anatomy
  - sysmod-architecture-kinds-and-coupling
  - sysmod-functional-analysis-chain
confidence: high
created: 2026-08-13
updated: 2026-08-13
referenced_by: [verification-validation]
---

# SYSMOD test modelling: Model Test Cases and the Test Architecture

## Contents

- Orientation
- Test Cases close the loop
- The test behaviour returns a verdict
- The Model Test Case
- What a Test Case is related to
- The Test Architecture
- Where the plugin diverges
- See also

## Orientation

The plugin's authoritative V&V surface is the `vv/` layer and the
`verification-validation` skill. [[vv-definitions]] fixes what
verification and validation each mean, [[vv-planning]] carries
planning, success criteria, and the verification cross-reference
matrix, and [[vv-methods]] carries the four standard methods and
test case design. The binding into the model is methodology §4.3.6
(the validation plan) and §5.4.6 (the verification plan). Read
those first.

This page adds two concepts from SYSMOD that the plugin's V&V
surface does not carry under those names: the Model Test Case, and
the Test Architecture as an architecture kind. Both are presented
notation-neutrally, and neither is plugin process.

## Test Cases close the loop

The Test Cases specify procedures for testing that the system
satisfies the requirements. The source states their purpose as
closing a loop: from the system requirements, through system
analysis to the architectures and the implementation, and back to
the requirements by way of the Test Cases. It places the picture in
the context of the V model.

The scope is bounded deliberately. SYSMOD considers Test Cases at
the system level only. Test cases at the level of the specific
engineering disciplines, such as software test cases, exist and are
outside the toolbox.

## The test behaviour returns a verdict

A Test Case in SYSMOD is a behavioural description of how to test
the system, and the source allows three shapes of it:

- a step by step work description of a manual test, written for a
  System Tester,
- a specification for test scripts, or
- an executable behaviour.

Whichever shape it takes, the defining property is the same. **The
Test Case behaviour returns a verdict that represents the test
result**, for example pass or fail. The verdict is what makes the
behaviour a test rather than a scenario walk, and it is the part of
the concept most worth carrying across notations.

## The Model Test Case

A Model Test Case is a special kind of Test Case that does not test
the system. It tests the model of the system, which is to say it
tests the specification. The method chapter puts the same point as
verifying or validating that the model virtually satisfies the
requirements instead of the real system doing so.

The distinction is a useful one to be able to name. A test that
runs against a specification and a test that runs against a
delivered system answer different questions, and a project that
calls both of them tests without qualification will eventually
report the first as evidence for the second.

## What a Test Case is related to

At the specification level the source fixes the relationships a
Test Case carries. Described notation-neutrally, they are:

| Relationship | Target | Purpose |
|---|---|---|
| Verify | The requirements the Test Case addresses | The trace that closes the loop back to the requirements |
| Dependency | The architectural elements used in the test | Records what the test needs in place to run |
| Dependency | Other Test Cases | Records ordering and prerequisite tests |
| Usage | Test data instances used by the Test Case | Records the data the test consumes |

The Test Case also owns a behaviour, with optional pre- and
postconditions and with control and object flow between its steps.
The modelling guidance places the whole set in a
verification-and-validation package and manages the Test Cases in a
table, and it notes that the document template for a Test Case
resembles the template for a System Use Case.

The inputs the method takes are the requirements and the Use Case
Activities. See [[sysmod-functional-analysis-chain]] for the
latter.

## The Test Architecture

The Test Architecture specifies the setup of the tests and of the
test systems themselves. Its top-level statement is how the system
under test is integrated into the test environment, where that
environment includes the test context, that is, the actors and the
test systems that perform the Test Cases.

Three properties define the concept.

- **It is an architecture kind.** The Test Architecture sits
  alongside the Base, Logical, and Product Architectures under
  Physical Architecture in the SYSMOD taxonomy. See
  [[sysmod-architecture-kinds-and-coupling]]. Structurally it is
  modelled the same way as any other architecture: a root element,
  part types with ports and constraints, a breakdown structure of
  part properties, connectors between parts and ports, and a
  context element that connects it to its actors.
- **A test system is a system in its own right.** Its specification
  may sit inside the Test Architecture, or the Test Architecture
  may only reference it while the specification lives in a separate
  system model, produced with SYSMOD or with any other methodology,
  in which the test system is the system of interest.
- **It always holds more than one setup.** The source is explicit
  that a Test Architecture consists of more than one test setup,
  and gives a user interaction test and a hardware-in-the-loop test
  as the example pair. Variant modelling techniques may be applied
  to specify the different setups.

The source also notes that the OMG UML Testing Profile can be
applied to a SysML model to mark up test architectures, naming the
system under test and the test context. That is a SysML v1 profile
mechanism and is recorded here only as source content.

## Where the plugin diverges

- **One construct carries both kinds of case.** The plugin declares
  a `verification def` for both the §4.3.6 validation plan and the
  §5.4.6 verification plan. The distinction is carried by what the
  case exercises and by where it lives: validation cases exercise
  stakeholder intent and reside under
  `core/verification-validation/validation-cases/`, verification
  cases exercise system internals and reside under
  `verification-cases/`. SYSMOD instead has one Test Case product
  that covers verifying and validating alike, and splits off the
  Model Test Case as a separate kind.
- **The binding target is an acceptance criterion.** In the plugin
  a case names an acceptance subrequirement of a story in its
  `objective`, so the trace runs case to story acceptance. In
  SYSMOD the verify relationship runs from the Test Case to a
  requirement, with the story concept absent from the source
  entirely.
- **There is no Model Test Case in the plugin.** Every plugin case
  is written against the model, because the model is the
  specification, so the source's distinction between testing the
  model and testing the real system has no direct counterpart. What
  the plugin distinguishes instead is verification timeframe, which
  [[vv-reporting-and-vse-guidance]] covers as continuous
  verification scaled for a very small entity.
- **There is no Test Architecture artefact.** The plugin's model
  package structure (§8.3) holds verification and validation cases,
  and no architecture kind for the test setup. A project that needs
  the test rig specified can model it, and gains no plugin support
  for doing so. The observation that a test system is a system in
  its own right remains sound advice for deciding whether that work
  belongs in this project's model at all.

## See also

- [[vv-definitions]] for what verification and validation mean in
  the plugin.
- [[vv-planning]] for planning, success criteria, and the
  verification cross-reference matrix.
- [[vv-methods]] for the four standard methods and test case
  design.
- [[vv-reporting-and-vse-guidance]] for records and continuous
  verification.
- [[sysmod-architecture-kinds-and-coupling]] for the taxonomy the
  Test Architecture belongs to.
- [[sysmod-toolbox-anatomy]] for the method and product structure
  these two artefacts sit in.
