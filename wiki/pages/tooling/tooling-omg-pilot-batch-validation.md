---
title: "OMG SysML v2 Pilot Implementation: installation and batch validation"
slug: tooling-omg-pilot-batch-validation
type: reference
layer: tooling
summary: Installing the OMG SysML v2 Pilot Implementation and validating a model through SysMLInteractive in batch
tags: [omg-pilot, installation, validation, java, jupyter, sysmlinteractive, exit-codes, standard-library]
sources:
  - citation: "Systems-Modeling. SysML v2 Pilot Implementation, release 2026-07, asset jupyter-sysml-kernel-0.61.0.zip. https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/releases/tag/2026-07 (accessed 2026-09)."
    raw: null
  - citation: "Systems-Modeling. SysML v2 Pilot Implementation repository README and Jupyter kernel notes. https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation (accessed 2026-09)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Validation runs of probe files and the demo model under the pilot 2026-07 on OpenJDK 21.0.12, recorded 2026-09-09."
    raw: null
related:
  - tooling-java-runtime
  - tooling-sysml-toolchain-choice
  - tooling-validator-fallback-process
  - tooling-reference-implementation-rules
  - tooling-opensysml-cli
  - sysml2-quantities-and-units
  - sysml2-api-and-services
confidence: high
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, sysml2-modelling]
---

# OMG SysML v2 Pilot Implementation: installation and batch validation

## Contents

- Java requirement
- Download and unpack
- Batch invocation
- Exit status and acceptance
- Output streams
- Multi-file models
- Cost
- Magics and other entry points
- Standard library gap
- Advanced alternatives
- See also

The OMG SysML v2 Pilot Implementation is the reference implementation of the language, maintained by the OMG Systems Modeling Community in the `Systems-Modeling/SysML-v2-Pilot-Implementation` repository. The release tag `2026-07`, published on 2026-08-20 and still the latest on 2026-09-09, ships Eclipse plugin version 0.61.0, conforming to KerML 1.1 Beta 2 and SysML 2.1 Beta 2, under the Eclipse Public License 2.0 with a GPL-2.0-or-later secondary licence. The plugin drives it as a batch validator through the Jupyter kernel jar, not as a notebook, so the whole Eclipse workbench stays out of the picture.

## Java requirement

Java 21 or later is a hard floor. The class files in the kernel jar carry major version 65 and the manifest states `Build-Jdk-Spec: 21`, so an older runtime refuses the classes before any model is read. The check is mechanical:

```bash
unzip -p "$JAR" org/omg/sysml/interactive/SysMLInteractive.class | head -c 8 | od -An -tx1
```

prints `ca fe ba be 00 00 00 41`, and 0x41 is 65. A headless runtime environment suffices, because the plugin only executes a jar. This page's validation runs used Ubuntu's `openjdk-21-jre-headless` package (OpenJDK 21.0.12). Installation routes per platform are on [[tooling-java-runtime]].

## Download and unpack

The release asset is `jupyter-sysml-kernel-0.61.0.zip`, 126,125,572 bytes. The release publishes no checksum file, so the value below was computed from the artefact and is what the plugin's install flow verifies against.

```bash
mkdir -p ~/.local/share/sysml-pilot
curl -sSfL -o ~/.local/share/sysml-pilot/jupyter-sysml-kernel-0.61.0.zip \
  https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/releases/download/2026-07/jupyter-sysml-kernel-0.61.0.zip
echo "3d310efb8a5332b11ec2441697d40ae10e7e04cfb8c8d121c198ffba38229ada  $HOME/.local/share/sysml-pilot/jupyter-sysml-kernel-0.61.0.zip" | sha256sum -c -
unzip -q ~/.local/share/sysml-pilot/jupyter-sysml-kernel-0.61.0.zip -d ~/.local/share/sysml-pilot
```

The unpacked tree holds `LICENSE`, `install.py`, `sysml/kernel.json`, `sysml/jupyter-sysml-kernel-0.61.0-all.jar` and `sysml/sysml.library`. The library is 95 files under three directories whose names contain spaces (`Domain Libraries`, `Kernel Libraries`, `Systems Library`). `install.py` registers a Jupyter kernelspec and needs `jupyter_client`, which the plugin never uses. Everything lives under the user's home, so no root privileges are involved.

## Batch invocation

The batch entry point is the class `org.omg.sysml.interactive.SysMLInteractive`, which reads a model from standard input and takes the library directory as its single positional argument.

```bash
PILOT="$HOME/.local/share/sysml-pilot/sysml"
LIB="$(cd "$PILOT/sysml.library" && pwd)"
{ printf '%%\n'; cat $(find model -name '*.sysml' | sort); printf '\n%%\n%%exit\n'; } \
  | timeout 300 java -cp "$PILOT/jupyter-sysml-kernel-0.61.0-all.jar" \
      org.omg.sysml.interactive.SysMLInteractive "$LIB"
```

Three details decide whether this works. A bare `%` line opens a block and the next bare `%` line closes it, so the model sits between two markers. `%exit` is mandatory: without it the process waits on its prompt forever. The library path must be absolute, because a relative path is percent-encoded by the underlying EMF resource loader and the run fails with exit 1 and a `FileNotFoundException` on `Kernel%20Libraries` before the first model line is read.

## Exit status and acceptance

The process exits 0 whether the model is clean, carries warnings, or is rejected. A non-zero status means the Java runtime failed, not that the model did: 1 for an uncaught exception (the relative library path above), 127 when `java` is missing, 124 when `timeout` expires. Acceptance therefore comes from parsing standard output. A clean run prints the root element line `N> Package <name> (<uuid>)` and no line matching `(^|> )(ERROR|WARNING):`. The prompt `N> ` is written without a newline, so the first diagnostic of a run lands on the prompt line, which is why the pattern tolerates the `> ` prefix. An error suppresses the root element line, a warning does not. Matching `ERROR:` alone corresponds to a plain `syside check`, and matching `ERROR|WARNING` corresponds to `syside check --warnings-as-errors`.

| Model submitted | Output | Exit |
|---|---|---|
| `package Good { part def Sensor; }` | `1> Package Good (<uuid>)` | 0 |
| duplicate inherited member | `1> WARNING:Duplicate of inherited member name ...` then `Package W1 (<uuid>)` | 0 |
| `package Broken { part def }` | `1> ERROR:no viable alternative at input '}' ...`, no root line | 0 |
| unresolved type | two `ERROR:` lines, no root line | 0 |

## Output streams

Standard output carries the banner `SysML v2 Pilot Implementation`, one `Reading <library file>...` line for each of the 94 model files in the library (the 95th file, `.index.json`, is not read as a model), and the diagnostics. Standard error carries three `log4j:WARN` lines about a missing appender configuration. That spelling has no colon after `WARN`, so it never collides with a `WARNING:` match.

## Multi-file models

Forward references do not resolve across blocks. Feeding one file per block produces spurious unresolved-namespace errors for every import that points at a later file, so a model tree is submitted as one block with every file concatenated. Diagnostics then read `(1.sysml line : N column : C)` with N counted from the first model line after the opening marker. The validator library keeps an offset table (file, first line, length) built from the same concatenation and maps N back to a file and a line. One Java process per commit is the rule, never one per file.

## Cost

Starting the runtime and reading the library take 8 to 12 seconds on the reference machine. The sixteen-file demo model validates in about 15 seconds wall time. That is fast enough for a pre-commit gate, and it is the reason the gate runs one process for all staged files.

## Magics and other entry points

The interactive class understands `%help`, `%eval`, `%list`, `%show`, `%publish`, `%viz`, `%view`, `%export`, `%load` and `%repo`. `%viz` needs a Graphviz `dot` executable and `%publish` needs a running API server, and the plugin uses neither. The jar also carries `org.omg.sysml.xtext.util.SysML2JSON` (`-l <library> [-d] [-g] [-v] <input-path>`, writing the standard JSON serialisation beside each input) and `SysML2XMI`. `java -jar` starts the Jupyter kernel itself, which expects a connection file and is not a validator.

## Standard library gap

The 2026-07 library declares no millisecond or microsecond unit. A model that writes `200 [ms]` declares the unit itself:

```sysml
attribute <ms> millisecond : DurationUnit {
    :>> unitConversion : ConversionByPrefix { :>> prefix = milli; :>> referenceUnit = s; }
}
```

with `ISQ::*`, `SI::*`, `SIPrefixes::*` and `MeasurementReferences::*` imported. See [[sysml2-quantities-and-units]] for the unit vocabulary.

## Advanced alternatives

Two thin Java programs give a real exit contract over the same jar: DeciSym's `sysmlv2-validator` (GNU-format diagnostics, built with Maven) and the `ValidateSysML.java` and KerML bridges that OpenSysML uses for its pilot differential. Both need Maven or a compiler, which the plugin cannot assume, so the plugin keeps to the batch class and parses its output.

## See also

- [[tooling-sysml-toolchain-choice]] for how this tool sits beside Syside and OpenSysML.
- [[tooling-validator-fallback-process]] for what the pre-commit gate does with it.
- [[tooling-reference-implementation-rules]] for the forms this tool refuses.
- [[tooling-opensysml-cli]] for the second open-source validator.
- [[sysml2-api-and-services]] for the standard API the JSON export serves.
