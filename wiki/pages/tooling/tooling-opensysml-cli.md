---
title: "OpenSysML: installation, CLI validation, and language server"
slug: tooling-opensysml-cli
type: reference
layer: tooling
summary: Installing OpenSysML, validating with sysml -validate, its exit codes, and wiring sysml-lsp as the editor server
tags: [opensysml, open-mbee, installation, validation, exit-codes, lsp, homebrew, go, document-generation]
sources:
  - citation: "Open-MBEE. OpenSysML release v0.6.0 assets and SHA256SUMS. https://github.com/Open-MBEE/OpenSysML/releases/tag/v0.6.0 (accessed 2026-09)."
    raw: null
  - citation: "Open-MBEE. OpenSysML README and the sysml -h command reference, release v0.6.0. https://github.com/Open-MBEE/OpenSysML (accessed 2026-09)."
    raw: null
  - citation: "vse-systems-engineering plugin (2026). Validation runs of probe files and the demo model under OpenSysML v0.6.0, recorded 2026-09-09."
    raw: null
related:
  - tooling-sysml-toolchain-choice
  - tooling-omg-pilot-batch-validation
  - tooling-validator-fallback-process
  - tooling-reference-implementation-rules
  - syside-project-configuration
  - sysml2-api-and-services
confidence: medium
created: 2026-09-10
updated: 2026-09-10
referenced_by: [sysml-toolchain, sysml2-modelling, document-export]
---

# OpenSysML: installation, CLI validation, and language server

## Contents

- Release binaries
- Installation
- Validation
- The pilot differential
- Language server
- Beyond validation
- See also

OpenSysML is a SysML v2 and KerML 1.1 implementation in Go from the Open-MBEE organisation, released under the Apache License 2.0. It ships as a single static binary with a command-line validator, an interactive shell, an execution runtime and a language server, and it bundles the standard library, so nothing else has to be installed beside it. The plugin uses it as the third toolchain in the fallback order and as the language server for projects on the OMG pilot, which has none.

Confidence note: this page is `medium` rather than `high` because the project is pre-1.0. Twenty releases landed in August 2026, and v0.6.0 of 2026-09-07 is markedly stricter than v0.2.1 was two weeks earlier. The flags and the diagnostic wording documented here were verified against v0.6.0 and may move without a compatibility path.

## Release binaries

Each release carries `opensysml-linux-amd64.tar.gz` and `opensysml-linux-arm64.tar.gz` (the `sysml` and `sysml-lsp` binaries at the top level plus a `share/` directory), the matching `darwin-amd64` and `darwin-arm64` archives, `opensysml-windows-amd64.zip`, a Windows MSI, bare `sysml-grpc-<os>-<arch>` files for the gRPC service, and `SHA256SUMS.txt` covering every archive. The Linux amd64 binaries are fully static and start on older glibc versions.

## Installation

The tarball route needs no privileges and lands in the user's own bin directory:

```bash
curl -sSfL -o /tmp/opensysml-linux-amd64.tar.gz \
  https://github.com/Open-MBEE/OpenSysML/releases/download/v0.6.0/opensysml-linux-amd64.tar.gz
echo "15d4a2d12a0adaadcbb1ed53946061a113c793e60a9e159b790936938323fc38  /tmp/opensysml-linux-amd64.tar.gz" | sha256sum -c -
mkdir -p ~/.local/bin && tar -xzf /tmp/opensysml-linux-amd64.tar.gz -C ~/.local/bin sysml sysml-lsp
```

The checksum comes from the release's `SHA256SUMS.txt`, which also lists the other archives. On macOS the recommended route is `brew install Open-MBEE/tap/opensysml`, which avoids the Gatekeeper quarantine that a browser download attaches to unsigned binaries. With a Go toolchain, `go install github.com/Open-MBEE/OpenSysML/cmd/sysml@v0.6.0` and `go install github.com/Open-MBEE/OpenSysML/cmd/sysml-lsp@v0.6.0` build both binaries into `$(go env GOPATH)/bin`. `sysml -version` prints `sysml v0.6.0` with the commit and build time. A binary built with `go install` may print `sysml dev` instead, which the plugin's detection accepts.

## Validation

```bash
sysml -validate -strict model/core/*.sysml model/library/*.sysml
```

`-validate` analyses the files and reports diagnostics. Flags accept a single or a double dash. The command takes many files and resolves names across them, so a model tree is passed as a list and no library path is needed. Exit status 0 means every file analysed cleanly, and warnings leave it at 0. Exit 1 means a check the model itself states answered false, which only the verdict commands produce. Exit 2 means the model could not be analysed: a syntax error, an unresolved name, an unreadable file or a misused flag. There is no warnings-as-errors switch, so the validator library greps the output for `warning:` when it wants Syside's strictness. `-strict` promotes the notation extensions that OpenSysML alone accepts (`defer` and the pseudostates) from warnings to errors and changes nothing else. `-quiet` reports errors only and `-json` reports checks as one JSON document.

Diagnostics are GNU style on standard error, `path:line:col: error: message` followed by a caret line under the offending token, and a successful run prints `✓ package <Name>` and `✓ <file>: no errors` on standard output.

## The pilot differential

The project measures every diagnostic against the pinned OMG pilot over the pilot's own corpora and publishes the disagreements, and it claims no conformance certification. In this plugin's own runs v0.6.0 agrees with the pilot on an attribute typed by an item definition, a connection typed by a usage, a `references` target that is a definition (`references target must be a usage, found requirementDef`), a `satisfy` target that is a constraint (`satisfy target must be a requirement usage, found constraintUsage`), and the `Bound features should have conforming types` warning. It alone refuses a `verify` whose target is a bare `require constraint`, which the pilot accepts. It does not enforce `#derive` on a definition, the `Only one subject is allowed` rule for a case objective, or the subject-first ordering in a requirement definition. A model that passes OpenSysML can therefore still fail the pilot, which is why the demo validates under both. The full list is on [[tooling-reference-implementation-rules]].

## Language server

`sysml-lsp` speaks the Language Server Protocol over standard input and output, bundles the standard library, and reports the same diagnostics as the command line. Strict conformance is switched on with the `-strict` argument or the `strictConformance` initialisation setting. The Claude Code IDE wiring is a `.lsp.json` at the project root:

```json
{
  "sysml": {
    "command": "sysml-lsp",
    "args": ["-stdio", "-strict"],
    "extensionToLanguage": { ".sysml": "sysml", ".kerml": "kerml" },
    "transport": "stdio",
    "initializationOptions": {},
    "restartOnCrash": true,
    "maxRestarts": 3
  }
}
```

The plugin ships this file as `templates/common/lsp-opensysml.json` and writes it for projects on `opensysml`, and for projects on `omg-pilot` when the binary is present, because the pilot ships no language server. See [[syside-project-configuration]] for the Syside counterpart.

## Beyond validation

The same binary renders views (`-render` in text, Mermaid or Markdown form), compiles document definitions to Markdown, HTML and PDF (`-render-document`), converts models to RDF (`-convert ttl`, experimental), runs calculations, constraints, actions and analysis cases, and serves a gRPC and Connect API with Python, Node, Java and Rust clients. An external SMT solver hooks into experimental `%check` and `%explain` commands. None of that is used by the plugin yet. Document rendering is recorded as future work for the document-export skill.

## See also

- [[tooling-sysml-toolchain-choice]] for the comparison with Syside and the pilot.
- [[tooling-omg-pilot-batch-validation]] for the reference implementation this tool measures itself against.
- [[tooling-validator-fallback-process]] for how the pre-commit gate calls it.
- [[sysml2-api-and-services]] for the standard API the gRPC service does not implement.
