---
title: "Sysand Package Management for SysML v2"
slug: syside-sysand-package-management
type: reference
layer: syside
summary: Sysand manifests, the lock file, KPAR packaging, the public index, and CI publishing for SysML v2
tags: [sysand, package-management, kpar, manifest, ci, interchange]
sources:
  - citation: "Sensmetry. Sysand documentation and CLI reference, release v0.2.0. https://docs.sensmetry.com/sysand/ (accessed 2026-08)."
    raw: null
  - citation: "Sensmetry. Sysand public package index. https://sysand.com (accessed 2026-08)."
    raw: null
related:
  - syside-tooling-overview
  - syside-project-configuration
  - vse-canonical-project-layout
  - vse-model-tiers-and-templates
  - sysml2-canonical-model-layout
confidence: high
created: 2026-08-07
updated: 2026-08-07
referenced_by: [project-setup, sysml2-modelling]
---

# Sysand Package Management for SysML v2

## Contents

- What Sysand is for
- Project manifests
- The lock file
- Command surface
- KPAR interchange packages
- The public index
- Publishing from CI
- Version stability

## What Sysand is for

Sysand is the open-source package manager for SysML v2 and KerML. It
does for a model what a language package manager does for source code:
it declares which external model libraries a project depends on, at
which versions, and resolves those declarations into a reproducible
set of files.

A VSE needs this the moment a second project reuses the same library.
Without a package manager, a shared library is copied between
repositories and drifts. With one, the library is a versioned
dependency and every project records which version it built against.
This is the mechanism behind the reuse that
[[vse-model-tiers-and-templates]] separates into tiers.

The facts on this page are current at release v0.2.0, August 2026.

## Project manifests

Sysand reads two manifest shapes, and the difference matters.

- `sysand.toml` is the project manifest a human edits. It names the
  project, its version, and its dependencies, in the same spirit as
  `syside.toml` for tooling configuration.
- `.project.json` and `.meta.json` are the interchange manifests
  defined by KerML clause 10.3. They describe a project and its
  metadata in the format the specification standardises, so a package
  produced by Sysand can be consumed by any conforming tool rather
  than only by the Sensmetry toolchain.

`sysand init` creates the project together with its manifests, metadata
the tool manages for you. Treat `sysand.toml` as the surface you edit
and consult the Sysand reference for how the interchange pair is kept
in step.

## The lock file

`sysand-lock.toml` records the exact resolved version of every
dependency, direct and transitive. Commit it. A lock file is what makes
a model build reproducible across engineers and across a CI runner, and
it is the difference between "the model validates on my machine" and
"the model validates".

The lock file is also a project root marker for Syside, so a project
that carries one is discoverable by the tooling even outside a git
working tree. See [[syside-project-configuration]].

## Command surface

| Command | What it does |
|---|---|
| `sysand init` | Create a new project with its manifests |
| `sysand add <package>` | Add a dependency to the project manifest |
| `sysand lock` | Resolve dependencies and write `sysand-lock.toml` |
| `sysand sync` | Bring the local environment in step with the lock file |
| `sysand env` | Inspect or manage the local package environment |
| `sysand build` | Produce a KPAR interchange package |
| `sysand publish` | Publish a package to an index |

The everyday VSE loop is `sysand add` followed by `sysand lock`, with
the changed manifest and lock file reviewed in the same pull request as
the model change that needed the dependency.

## KPAR interchange packages

`sysand build` produces a KPAR file, the interchange package format for
SysML v2. A KPAR bundles the model files together with the KerML 10.3
interchange manifests, so it is a self-describing archive rather than a
directory of loose `.sysml` files.

KPAR is the artefact a VSE hands to an acquirer or to a partner who
runs a different toolchain, and it is the artefact the index stores.

## The public index

sysand.com hosts the public package index. Packages are namespaced by
publisher, so an organisation publishes under its own namespace and a
name collision between two publishers is impossible.

A VSE working on confidential material does not have to publish
anything. Dependencies may be resolved from a local path or from a
private location, and only a package intended for reuse outside the
organisation goes to the public index.

## Publishing from CI

Sysand ships a GitHub Action for publishing from a workflow, which is
the supported way to make publication a consequence of a release rather
than a manual step an engineer remembers. The pattern that fits the
methodology: publish on the release tag, not on every merge, so the
published version and the baseline tag agree.

Store the index credential in the repository secret store, exactly as
the Syside deployment licence key is stored for the validation
workflow.

## Version stability

Sysand is pre-v1.0, and v1.0 is planned alongside Syside v1.0 in Q3
2026 (see [[syside-tooling-overview]] for the roadmap and its caveat).
Command names and manifest keys may still change. Pin the Sysand
Dependencies can also come from a privately hosted index, which the
Sysand documentation covers as a first-class setup. A VSE working on
confidential material does not have to publish anything to the public
index.
