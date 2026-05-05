# Wiki Activity Log

Append-only record of wiki operations. Prefix tags are `source-added`,
`ingest`, `refactor`, `lint`, `bundle`. See `CLAUDE.md` for the full
convention.

## [2026-04-16] bundle | scaffolding

Wiki subsystem scaffolded. `CLAUDE.md`, `INDEX.md`, and this log created.
Schema templates installed under `schema/`. Layer directories created
under `pages/` (all empty). `bundles/` directory created (empty). No
content ingested yet. Migration from the legacy `knowledge/` directory
starts in a subsequent PR with the four oversized files as the first
slice.

## [2026-05-04] source-added | sysmlv2.pdf

Raw file replaced with the 2026-04 release of "The SysML v2 Book"
(Weilkiens and Molnár, MBSE4U). Stub appended manually because the
file was modified outside Claude, so the source-added-reminder hook
did not fire. Release notes record new material in Part II Chapter 17
(self and that), Chapter 21 (binding connectors), Section 24.3
(advanced quantities and units), Chapter 25 (occurrences and 4D
modelling), and Chapter 39 (model execution).

## [2026-05-04] ingest | sysmlv2.pdf 2026-04 (new chapters)

Layer: sysml2. Pages authored from the 2026-04 release deltas:

- sysml2-self-and-that (new, Section 17.3)
- sysml2-binding-connectors (new, Chapter 21)
- sysml2-advanced-quantities-units (new, Section 24.3)
- sysml2-occurrences-4d (new, Sections 25.1 to 25.2)
- sysml2-portions-and-individuals (new, Sections 25.3 to 25.4)
- sysml2-temporal-spatial-relations (new, Sections 25.5 to 25.7)
- sysml2-occurrence-context-and-variables (new, Sections 25.8 to 25.10)
- sysml2-model-execution (new, Chapter 39)

Bundles regenerated: sysml2-allocations, sysml2-behaviour,
sysml2-expressions. Stub for sysmlv2.pdf marked ingested by this entry.

## [2026-05-04] ingest | knowledge/sysml2-variants-ref.md

Layer: sysml2. Pages authored from atomisation of legacy reference:

- sysml2-variations-overview (new, concept)
- sysml2-variation-definitions (new, reference)
- sysml2-variant-configuration (new, reference)
- sysml2-variant-patterns (new, pattern)

Bundles regenerated: sysml2-variants. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-views-ref.md

Layer: sysml2. Pages authored:

- sysml2-viewpoints-and-concerns (new, concept)
- sysml2-view-definitions (new, reference)
- sysml2-standard-views (new, reference)
- sysml2-view-patterns (new, pattern)

Bundles regenerated: sysml2-views. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-allocations-ref.md

Layer: sysml2. Pages authored:

- sysml2-allocations-overview (new, concept)
- sysml2-allocation-definitions (new, reference)
- sysml2-allocation-patterns (new, pattern)

Bundles regenerated: sysml2-allocations. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-cases-ref.md

Layer: sysml2. Pages authored:

- sysml2-cases-overview (new, concept)
- sysml2-case-kinds (new, reference)
- sysml2-case-patterns (new, pattern)

Bundles regenerated: sysml2-cases. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-behaviour-ref.md

Layer: sysml2. Pages authored:

- sysml2-actions (new, reference)
- sysml2-successions (new, reference)
- sysml2-special-action-usages (new, reference)
- sysml2-state-machines (new, reference)
- sysml2-flows-and-messages (new, reference)
- sysml2-behaviour-patterns (new, pattern)

Bundles regenerated: sysml2-behaviour. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-expressions-ref.md

Layer: sysml2. Pages authored:

- sysml2-expressions-overview (new, reference)
- sysml2-sequences-and-structures (new, reference)
- sysml2-functions-and-higher-order (new, reference)
- sysml2-expressions-constraints (new, reference)
- sysml2-expression-patterns (new, pattern)

Bundles regenerated: sysml2-expressions. Legacy file removed.

## [2026-05-04] bundle | phase-1a migration

Bundles regenerated: sysml2-allocations (4 pages), sysml2-behaviour
(12 pages), sysml2-cases (3 pages), sysml2-expressions (6 pages),
sysml2-variants (4 pages), sysml2-views (4 pages). INDEX.md rebuilt
with 33 atomic pages across the sysml2 layer.

## [2026-05-04] lint | post-ingest

Pages scanned: 33. Bundles scanned: 6. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 1a migration.

## [2026-05-04] ingest | knowledge/sysml2-metadata-ref.md

Layer: sysml2. Pages authored from atomisation of legacy reference:

- sysml2-metadata-overview (new, concept)
- sysml2-metadata-definitions (new, reference)
- sysml2-reflection-and-classification (new, reference)
- sysml2-filter-conditions (new, reference)
- sysml2-language-extension (new, reference)
- sysml2-vse-library-metadata (new, pattern)

Bundles regenerated: sysml2-metadata. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-libraries-ref.md

Layer: sysml2. Pages authored:

- sysml2-libraries-architecture (new, concept)
- sysml2-systems-model-library (new, reference)
- sysml2-domain-libraries-metadata-analysis (new, reference)
- sysml2-domain-libraries-causation-geometry (new, reference)
- sysml2-library-import-patterns (new, pattern)
- sysml2-quantities-and-units (new, reference)

Bundles regenerated: sysml2-modelling. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-quick-ref.md

Layer: sysml2. Pages authored:

- sysml2-syntax-packages-and-definitions (new, reference)
- sysml2-syntax-features-and-attributes (new, reference)
- sysml2-syntax-structure (new, reference)
- sysml2-syntax-behaviour (new, reference)
- sysml2-syntax-requirements-and-cases (new, reference)

Bundles regenerated: sysml2-modelling. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-semantics-ref.md

Layer: sysml2. Pages authored:

- sysml2-language-architecture (new, concept)
- sysml2-type-hierarchy (new, reference)
- sysml2-specialisation-and-typing (new, reference)
- sysml2-structural-and-behavioural-semantics (new, reference)
- sysml2-requirements-semantics (new, reference)
- sysml2-grammar-and-validation (new, reference)

Bundles regenerated: sysml2-modelling. Legacy file removed.

## [2026-05-04] ingest | knowledge/sysml2-model-structure-ref.md

Layer: sysml2. Pages authored from a multi-source reference (Douglass
2016, Douglass 2021, SysML v2 Book Chapters 14-16, VAMOS 2016, ISO
29110, Galinier et al.):

- sysml2-canonical-model-layout (new, concept)
- sysml2-base-architecture-and-federation (new, reference)
- sysml2-namespace-hygiene (new, reference)
- sysml2-variant-organisation (new, pattern)
- sysml2-model-cm-and-risks (new, pattern)

Bundles regenerated: sysml2-model-structure. Legacy file removed.

## [2026-05-04] bundle | phase-1b migration

Bundles regenerated: sysml2-allocations (4 pages), sysml2-behaviour
(12 pages), sysml2-cases (3 pages), sysml2-expressions (6 pages),
sysml2-metadata (6 pages), sysml2-model-structure (5 pages),
sysml2-modelling (17 pages), sysml2-variants (4 pages), sysml2-views
(4 pages). INDEX.md rebuilt with 61 atomic pages across the sysml2
layer.

## [2026-05-04] lint | post-phase-1b

Pages scanned: 61. Bundles scanned: 9. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 1b migration. The full SysML 2.0 layer
is now atomised.

## [2026-05-04] ingest | knowledge/iso29110-profile.md

Layer: iso29110. Pages authored:

- iso29110-overview (new, concept)
- iso29110-pm-process (new, reference)
- iso29110-sr-process (new, reference)
- iso29110-roles-and-work-products (new, reference)
- iso29110-phase-gates (new, process)

Cross-layer wikilinks added: PM.O6 references
sysml2-vse-library-metadata; SR.O2 references
sysml2-syntax-requirements-and-cases and sysml2-requirements-semantics;
SR.O6 references sysml2-vse-library-metadata; SR.O7 references
sysml2-cases-overview and sysml2-case-kinds. Bundles regenerated:
project-setup, iteration-orchestrator. Legacy file removed.

## [2026-05-04] ingest | knowledge/iso29110-task-lists.md

Layer: iso29110. Pages authored:

- iso29110-pm-task-checklists (new, process)
- iso29110-sr-task-checklists (new, process)
- iso29110-template-mapping (new, reference)

Cross-layer wikilinks added: SR.2 task list references
sysml2-syntax-requirements-and-cases; SR.3 references
sysml2-canonical-model-layout and sysml2-allocations-overview; SR.5
references sysml2-cases-overview and sysml2-case-kinds. Bundles
regenerated: project-setup, iteration-orchestrator. Legacy file
removed.

## [2026-05-04] ingest | knowledge/iteration-centred-operation.md

Layer: project-structure. Pages authored:

- iteration-centred-operation (new, concept)
- iteration-boundary-and-macrocycle-closure (new, process)

Bundled by iteration-orchestrator and project-setup. The original
file's broader claim of consumption by vse-companion-overview and
needs-and-requirements was reduced to match actual `!cat` embeds:
both skills only mention the file in prose, not as a runtime embed.
Legacy file removed.

## [2026-05-04] ingest | knowledge/canonical-project-structure.md

Layer: project-structure. Pages authored:

- vse-canonical-project-layout (new, reference)
- vse-model-tiers-and-templates (new, reference)

Cross-layer wikilinks added: model-tiers references
sysml2-canonical-model-layout (the AMBSE package set the tiers
materialise) and sysml2-vse-library-metadata (the metadata shipped
in `library/vse-library.sysml`). Bundles regenerated: project-setup,
project-audit. Legacy file removed.

## [2026-05-04] bundle | phase-2 migration

Bundles regenerated: project-setup (12 pages), iteration-orchestrator
(10 pages), project-audit (2 pages). Phase 2 created three new
bundles for skills that previously consumed only flat knowledge
files. All 12 SysML 2.0 bundles regenerated unchanged. INDEX.md
rebuilt with 73 atomic pages across two populated layers (sysml2 and
project-structure) plus iso29110.

## [2026-05-04] lint | post-phase-2

Pages scanned: 73. Bundles scanned: 12. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 2 migration. Process-backbone layer
atomised.

## [2026-05-04] ingest | knowledge/ambse-agile-process.md

Layer: ambse. Pages authored:

- ambse-principles (new, reference)
- ambse-vee-three-timeframes (new, reference)
- ambse-iteration-planning (new, reference)
- ambse-risk-and-metrics (new, reference)
- ambse-iso29110-mapping (new, reference)

Cross-layer wikilinks added: principles, three-timeframes,
iteration-planning, and iso29110-mapping link into the iso29110
layer (iso29110-pm-process, iso29110-sr-process, iso29110-pm-task-checklists,
iso29110-sr-task-checklists) and into the project-structure layer
(iteration-centred-operation, iteration-boundary-and-macrocycle-closure).
Bundles regenerated: iteration-orchestrator. Legacy file removed.

## [2026-05-04] ingest | knowledge/ambse-requirements.md

Layer: ambse. Pages authored:

- ambse-requirements-as-models (new, reference)
- ambse-use-case-driven-elicitation (new, reference)
- ambse-system-requirements-derivation (new, reference)
- ambse-nanocycle-and-use-case-analysis (new, reference)
- ambse-dependability-and-traceability (new, reference)

Cross-layer wikilinks added: every page links into sysml2
(sysml2-syntax-requirements-and-cases, sysml2-requirements-semantics,
sysml2-cases-overview, sysml2-case-kinds, sysml2-case-patterns) per
the Phase 3+ cross-layer rule, and into needs-and-reqs (writing-good-requirements,
needs-vs-requirements). Bundles regenerated: needs-and-requirements.
Legacy file removed.

## [2026-05-04] ingest | knowledge/ambse-architecture.md

Layer: ambse. Pages authored:

- ambse-architecture-analysis (new, reference)
- ambse-trade-studies (new, reference)
- ambse-architectural-design (new, reference)
- ambse-interfaces-and-handoff (new, reference)
- ambse-architecture-vv-and-iso29110 (new, reference)

Cross-layer wikilinks added: architecture-analysis links into
sysml2-canonical-model-layout, sysml2-base-architecture-and-federation,
sysml2-allocations-overview; trade-studies links into
sysml2-views-overview; interfaces-and-handoff links into
sysml2-binding-connectors and sysml2-allocations-overview;
architecture-vv-and-iso29110 links into vv-process-and-incose
and iso29110-sr-process. Bundles regenerated: architecture-design,
verification-validation. Legacy file removed.

## [2026-05-04] ingest | knowledge/ambse-git-workflow.md

Layer: ambse. Pages authored:

- ambse-git-three-way-mapping (new, reference)
- ambse-git-nanocycle-commits (new, reference)
- ambse-git-microcycle-prs (new, reference)
- ambse-git-ci-gates-and-macrocycle (new, reference)
- ambse-git-vse-guidance-and-anti-patterns (new, reference)

Cross-layer wikilinks added: pages link into ambse-vee-three-timeframes
(timeframe mapping), iteration-centred-operation,
iteration-boundary-and-macrocycle-closure, and the iso29110 layer
where work products attach to commits and PRs. Bundles regenerated:
iteration-orchestrator. Legacy file removed.

## [2026-05-04] bundle | phase-4 migration

Bundles regenerated: iteration-orchestrator (20 pages, +10 from
ambse-agile-process and ambse-git-workflow), needs-and-requirements
(13 pages, +5 from ambse-requirements), architecture-design (5
pages, new bundle for architecture-design skill),
verification-validation (6 pages, +2 from ambse cross-cluster).
INDEX.md rebuilt with 109 atomic pages across nine populated layers.

## [2026-05-04] lint | post-phase-4

Pages scanned: 109. Bundles scanned: 16. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 4 migration. AMBSE cluster atomised
into four sub-clusters with full cross-layer linking into iso29110,
project-structure, sysml2, vv, and needs-and-reqs.

## [2026-05-04] ingest | knowledge/syside-automator-ref.md

Layer: syside. Pages authored:

- syside-tooling-overview (new, reference)
- syside-project-configuration (new, reference)
- syside-core-api (new, reference)
- syside-expression-evaluation (new, reference)
- syside-model-modification (new, reference)
- syside-vse-workflows (new, pattern)

Cross-layer wikilinks added: tooling-overview links into
project-structure/vse-canonical-project-layout and
sysml2/sysml2-canonical-model-layout; project-configuration links
into project-structure layer and vse-model-tiers-and-templates;
core-api links into sysml2-syntax-packages-and-definitions and
sysml2-canonical-model-layout; expression-evaluation links into
sysml2-expressions-overview, sysml2-advanced-quantities-units, and
sysml2-metadata-overview; model-modification links into
sysml2-syntax-packages-and-definitions and
sysml2-canonical-model-layout; vse-workflows links into
sysml2-syntax-requirements-and-cases, sysml2-allocations-overview,
ambse-dependability-and-traceability, and vse-model-tiers-and-templates.
Bundles regenerated: sysml2-modelling, sysml2-metadata,
project-setup. Legacy file removed.

## [2026-05-04] ingest | knowledge/incose-vse-practices.md

Layer: incose-vse. Pages authored:

- incose-vse-lifecycle-models (new, concept)
- incose-vse-stakeholder-needs (new, concept)
- incose-vse-requirements-engineering (new, concept)
- incose-vse-architecture-and-vv (new, concept)
- incose-vse-cm-risk-and-scaling (new, concept)

Cross-layer wikilinks added: lifecycle-models links into
ambse-principles, ambse-vee-three-timeframes,
ambse-iteration-planning, iso29110-pm-process, and
iso29110-sr-process; stakeholder-needs links into
needs-vs-requirements, requirements-elicitation-and-writing,
ambse-use-case-driven-elicitation, ambse-requirements-as-models,
and sysml2-cases-overview; requirements-engineering links into
requirements-elicitation-and-writing, ambse-requirements-as-models,
ambse-system-requirements-derivation,
ambse-dependability-and-traceability,
sysml2-syntax-requirements-and-cases, and
sysml2-requirements-semantics; architecture-and-vv links into
ambse-architecture-analysis, ambse-trade-studies,
ambse-architectural-design, ambse-architecture-vv-and-iso29110,
vv-methods, sysml2-canonical-model-layout, and
sysml2-allocations-overview; cm-risk-and-scaling links into
iso29110-pm-process, iso29110-sr-process, iso29110-overview,
vse-canonical-project-layout, ambse-iso29110-mapping,
ambse-risk-and-metrics, and sysml2-vse-library-metadata. Bundles
regenerated: iteration-orchestrator. Legacy file removed.

## [2026-05-04] bundle | phase-5 migration

Bundles regenerated: sysml2-modelling (23 pages, 2,848 lines, +6
SySiDE pages), sysml2-metadata (11 pages, 1,388 lines, +5 SySiDE
pages), project-setup (15 pages, 1,809 lines, +3 SySiDE pages),
iteration-orchestrator (25 pages, 2,810 lines, +5 INCOSE VSE
pages). INDEX.md rebuilt with 120 atomic pages across 11
populated layers.

## [2026-05-04] lint | post-phase-5

Pages scanned: 120. Bundles scanned: 16. ERROR: 0. WARN: 0. INFO: 0.
Wiki state clean after Phase 5 migration. The two remaining
non-SysML knowledge files are now atomised. Only knowledge/INDEX.md
remains in the legacy directory, scheduled for deletion in Phase 6
(1.0.0 release).

## [2026-05-04] cleanup | knowledge/ directory deleted

Phase 6 completion. The `knowledge/` directory has been deleted in
full, including the redirect `INDEX.md` and the empty `.gitkeep`.
Eight stale prose references rewritten in five skills
(architecture-design, needs-and-requirements, project-setup,
iteration-orchestrator, vse-companion-overview) to point at atomic
pages and bundles. The `vse-wiki-lint` rule that flagged migration-era
INFO findings escalated to a WARN-on-stale-knowledge-references rule.
README.md, wiki/CLAUDE.md, and CLAUDE.local.md updated to reflect the
single-surface architecture. Plugin version bumped to 1.0.0 to mark
the consolidation milestone.

## [2026-05-05] refactor | sysmlv2.pdf Ch 41 atomisation, new sysml2-extension skill

Layer: sysml2. Atomic split of the existing `sysml2-language-extension`
page into four sibling pages, and a new `sysml2-extension` skill that
owns the producer side of language extension (declaring domain
libraries, registering user-defined keywords).

Pages new:

- sysml2-domain-model-libraries (reference, Ch 41.1, library packages
  and the PBSE example)
- sysml2-user-defined-keywords (reference, Ch 41.2, SemanticMetadata
  pattern and the meta-cast)
- sysml2-extension-gotchas (pattern, Ch 41.2 pp 295-297, the three
  silent-failure pitfalls)

Pages updated:

- sysml2-language-extension (retitled to overview, body rewritten as a
  hub pointing at the three new siblings, citation page numbers
  updated for the 2026-04 release from 265-271 to 291-297, type
  changed from reference to concept, bundled_by moved from
  sysml2-metadata to sysml2-extension).

Skills new:

- sysml2-extension (producer side: domain libraries, user-defined
  keywords, the three pitfalls).

Skills updated:

- sysml2-metadata (description trimmed to remove "user-defined
  keywords"; the user-defined-keyword subsection collapsed to a
  routing pointer to @sysml2-extension; SemanticMetadata vocabulary
  row removed from the core-vocabulary table; checklist items 1, 3
  and the matching red-flag bullet removed since they now belong to
  @sysml2-extension).

Bundles regenerated: sysml2-extension (new, 4 pages), sysml2-metadata
(11 → 10 pages).

Note on page-numbering shift. The 2026-04 release of "The SysML v2
Book" has Chapter 41 at content pp 291-297; earlier book drafts had
the same content at pp 265-271. The content has not changed, only the
pagination. Citations now point at the current pages.

## [2026-05-05] refactor | story-driven AMBSE methodology layer

Phase 5 of the v2.0 plugin restructuring. The wiki adopts the
plugin's new methodology specification (`<plugin>/methodology/`,
introduced in PR #33).

Pages deleted (cycle-centric, superseded by the methodology layer):
- ambse/ambse-git-nanocycle-commits
- ambse/ambse-git-microcycle-prs
- ambse/ambse-git-ci-gates-and-macrocycle
- ambse/ambse-git-three-way-mapping
- ambse/ambse-git-vse-guidance-and-anti-patterns
- ambse/ambse-vee-three-timeframes
- ambse/ambse-iteration-planning
- ambse/ambse-nanocycle-and-use-case-analysis
- project-structure/iteration-boundary-and-macrocycle-closure
- project-structure/iteration-centred-operation

Layer added: methodology (16 atomic pages) summarising §0-§10 of the
methodology specification:
- methodology-overview
- user-story-canonical-artefact
- frame-concern-pattern
- role-actor-coupling
- benefit-as-criterion
- storymeta-lifecycle
- base-architecture-corollaries
- system-context-completeness
- stakeholder-stories-workflow
- system-stories-workflow
- architectural-analysis-workflow
- architectural-design-workflow
- story-branch-pr-workflow
- iso-29110-compliance-mapping
- project-management-workflow
- methodology-library-packaging

Bundles regenerated. iteration-orchestrator bundle removed (skill
decommissioned in PR #35). Five new bundles added: story-orchestrator,
release-orchestrator, change-request, project-plan,
vse-companion-overview. The remaining bundles include relevant
methodology pages per their `bundled_by` lists.

Bulk replacements:
- `bundled_by: iteration-orchestrator` rewritten to `release-orchestrator`
  in 19 surviving pages (closest semantic successor for the lifecycle
  reference role the iteration-orchestrator skill played).
- Wikilinks to deleted pages rewritten to point at the closest
  methodology-layer successor (typically [[story-branch-pr-workflow]]
  or [[methodology-overview]]).

Totals after the refactor: 129 atomic pages across 11 layers
(methodology added; project-structure shrunk by two; ambse shrunk by
eight). 21 bundles (was 17 plus 5 new minus 1 decommissioned).
