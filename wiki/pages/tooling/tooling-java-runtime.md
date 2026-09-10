---
title: "Java 21 runtime for the OMG pilot"
slug: tooling-java-runtime
type: reference
layer: tooling
summary: Installing a Java 21 runtime per platform for the OMG pilot, JRE versus JDK, JAVA_HOME, and the version check
tags: [java, jre, jdk, temurin, openjdk, installation, omg-pilot, ci]
sources:
  - citation: "Eclipse Adoptium. Temurin installation guides for Linux, macOS and Windows. https://adoptium.net/installation/ (accessed 2026-09)."
    raw: null
  - citation: "Homebrew. Cask temurin@21. https://formulae.brew.sh/cask/temurin@21 (accessed 2026-09)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Pilot runs on Ubuntu 24.04 under WSL2 with openjdk-21-jre-headless, recorded 2026-09-09."
    raw: null
related:
  - tooling-omg-pilot-batch-validation
  - tooling-sysml-toolchain-choice
  - tooling-validator-fallback-process
confidence: high
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, attention-regime]
---

# Java 21 runtime for the OMG pilot

Java is a certain prerequisite of one toolchain. The OMG SysML v2 Pilot Implementation is a Java program and needs a runtime on the machine that validates. OpenSysML does not depend on Java. The Syside command-line tool ships a Java component for its diagram export, and whether `syside check` needs a runtime is not recorded, so a project that never chooses the pilot installs Java only if Syside asks for it.

## The floor

Java 21 or later. The kernel jar of the 2026-07 release carries class files with major version 65 and a manifest line `Build-Jdk-Spec: 21`, and an older runtime rejects the classes before the model is read. The evidence and the one-line check are on [[tooling-omg-pilot-batch-validation]].

## JRE or JDK

A headless runtime environment is enough, because the plugin only runs a jar and never compiles Java. The reference runs behind this layer used Ubuntu's `openjdk-21-jre-headless` package. A full development kit is needed only for the advanced Java bridges that compile against the pilot jar, which the plugin does not use.

## Installation per platform

The plugin shows the command and runs a system package manager only after the engineer approves that step. Where a route without root privileges exists, the plugin offers it first.

- Debian, Ubuntu and WSL: `sudo apt install openjdk-21-jre-headless`. The Temurin build is an alternative through the Adoptium repository, followed by `sudo apt install temurin-21-jdk`.
- Fedora and RHEL: `sudo dnf install java-21-openjdk-headless`, or `sudo dnf install temurin-21-jdk` with the Adoptium repository configured.
- macOS: `brew install --cask temurin@21`.
- Windows: `winget install -e --id EclipseAdoptium.Temurin.21.JDK`.
- Without root privileges on any platform: unpack a Temurin 21 archive from adoptium.net under `~/.local/share/java/<version>` and export `JAVA_HOME` to that directory in the shell profile.

## How the wrapper finds Java

The validator library resolves the runtime in this order: the `VSE_JAVA` variable when set, then `$JAVA_HOME/bin/java`, then `java` on the PATH. The first candidate whose version major is 21 or more wins, and a candidate that is too old is reported by version so the engineer sees which one was tried.

## Version check

```bash
java -version 2>&1 | head -1
```

prints a line such as `openjdk version "21.0.12" 2026-07-21`. The number before the first dot is the major version and must be 21 or more. The old `1.8` numbering identifies Java 8 and fails the check.

## Continuous integration

The shipped workflow templates run `actions/setup-java@v4` with `distribution: temurin` and `java-version: '21'` before validating, which installs the runtime and sets `JAVA_HOME` on the runner. Projects on OpenSysML skip that step.

## See also

- [[tooling-omg-pilot-batch-validation]] for the tool that needs this runtime.
- [[tooling-sysml-toolchain-choice]] for choosing between the three toolchains.
- [[tooling-validator-fallback-process]] for what the gate does when Java is missing.
