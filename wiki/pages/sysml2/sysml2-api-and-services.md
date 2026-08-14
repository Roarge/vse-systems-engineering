---
title: "Systems Modeling API and Services"
slug: sysml2-api-and-services
type: reference
layer: sysml2
summary: The Systems Modeling API and Services, its PIM data structures and services for tool-independent model access
tags: [api, services, pim, psm, interoperability, versioning, digital-thread]
sources:
  - citation: "Weilkiens T and Molnár V (2026). The SysML v2 Book, 2026-07 release. MBSE4U. Chapter 42, pages 331 to 335."
    raw: sysmlv2.pdf
related:
  - sysml2-language-architecture
  - syside-core-api
confidence: high
created: 2026-08-14
updated: 2026-08-14
referenced_by: [sysml2-modelling]
---

# Systems Modeling API and Services

## Contents

- What the standard is
- PIM data structures
- PIM services
- Not the Syside Automator API
- Status in the 2026-07 release
- See also

A separate OMG specification defining a standard programmatic
interface to SysML 2.0 models.

## What the standard is

The Systems Modeling API and Services is deeply intertwined with the
SysML v2 standard but is a distinct specification in its own right. It
is frequently called the "SysML v2 API", although that is not its
official name. It is a universal, standard interface for any model
based on KerML, the kernel language underneath SysML 2.0. Viewed
narrowly it is one more API, but it gives tool-agnostic access to
system models, which breaks down data silos, removes vendor lock-in,
and is a critical enabler for a digital thread across the product
lifecycle (Ch 42, p 331). Lock-in costs a VSE most, because a very
small organisation has the least capacity to migrate a model estate
later.

Following Model-Driven Architecture principles, the specification
splits into two layers. The **Platform Independent Model (PIM)** is
the core layer, specifying the capabilities, data structures, and
logic of the API independently of any technology, and prescribing the
architecture of the layer below. The **Platform Specific Models
(PSMs)** map the PIM onto deployable technologies, and the standard
officially defines two, a REST/HTTP API and an OSLC (Open Services for
Lifecycle Collaboration) API. Other mappings are permitted, and the
PIM stays identical in each. A tool may conform to the PIM alone and
supply its own implementation, or conform to one of the specified
PSMs, and both are conformance levels of the standard (Ch 42, p 331).
These are conformance levels of the API specification, not the five
conformance levels of the SysML 2.0 language specification in
[[sysml2-language-architecture]].

Model management is part of the standard, which is less obvious.
Models are organised into projects and are subject to Git-inspired
versioning with commits (versions), branches, and tags (Ch 42, p 331).

## PIM data structures

Everything sent to and retrieved from the API is based on `Record`. A
record is a container, and its attributes describe that container
rather than the data inside it, so a record name has nothing to do
with the names of model elements. Records name things such as a
project or a commit (Ch 42, pp 332 to 334).

| Record | What it is |
|---|---|
| `Record` | The base structure: a UUID, an IRI, and optionally a name, many aliases, and a description |
| `Project` | Model elements as a logical unit, not itself a package model element. Holds commits, tags, and branches, with exactly one default branch |
| `Commit` | A change to a project at a point in time, referencing its preceding commits, usually one, or several after a merge |
| `Branch`, `Tag` | Both `CommitReference`s. A branch is a line of development referencing its head commit. A tag annotates commits, such as a release or milestone |
| `DataIdentity` | A version-independent data entity across its lifecycle |
| `DataVersion` | The versions of that data, pointing at exactly one commit owned by a project |
| `Data` | The interface the data sits behind, implemented by `Element`, `Relationship`, `ExternalElement`, `ExternalRelationship`, and `ProjectUsage` |
| `Element`, `Relationship` | The KerML model elements that found every KerML and SysML 2.0 model element |
| `ExternalRelationship` | Connects an `Element` to an `ExternalData` entity, specifying the mapping and its language, for example Python, which is not part of the standard |
| `ProjectUsage` | The use of one project within another |
| `Query` | A request to retrieve information from a project, implementable in a language such as SQL or SPARQL |

A part definition named `Engine` therefore appears in the API as an
Element associated through the Data interface with exactly one
DataVersion, which refers to exactly one DataIdentity (Ch 42, p 333).

## PIM services

The PIM specifies six services (Ch 42, p 334):

| Service | Concern |
|---|---|
| `ProjectService` | Projects |
| `ElementNavigationService` | Navigation over model elements |
| `ProjectDataVersioningService` | Commits, branches, and tags |
| `QueryService` | Queries |
| `ExternalRelationshipService` | Links to external data |
| `ProjectUsageService` | Use of one project within another |

The services mainly describe how data is read, updated, created, and
deleted. `ProjectService` is the illustrative case, offering retrieval
of all projects or of one by identifier, plus creation, update, and
deletion. The others are much the same, and some add features of their
own, as `QueryService` can execute a query as well as create, update,
and delete one (Ch 42, pp 334 to 335). The exact method of access
depends on the technology and is specified in the platform specific
models (Ch 42, p 331).

## Not the Syside Automator API

Two different things are called an API in this knowledge base. The
Systems Modeling API and Services on this page is an OMG standard,
vendor-neutral, defining what any conforming tool must offer. The
Syside Automator Python library in [[syside-core-api]] is a Sensmetry
product API for loading, querying, and traversing models from Python.
Choosing the Automator is a tooling decision, whereas conformance to
the OMG API is an interoperability property of a tool. Reach for the
Automator when scripting against a local model, and for the OMG
standard when exchanging models between tools or avoiding lock-in.

## Status in the 2026-07 release

Chapter 42 is an overview, and the book points to Chapter 44 and the
standard itself for the complete list of data structures and services
(Ch 42, p 332). Neither downstream chapter has content yet. Chapter 43,
covering getting started and examples, is marked for publication in a
later release (Ch 43, p 336), as is Chapter 44, which is to hold the
reference material for the API and the REST/HTTP and OSLC
implementations (Ch 44, p 337). Guidance on using the API cannot be
sourced from this book yet, so revisit this page when those chapters
publish.

## See also

- [[sysml2-language-architecture]] for the KerML and SysML layering
  the API is built on.
- [[syside-core-api]] for the Syside Automator Python library, which
  is a different API.
