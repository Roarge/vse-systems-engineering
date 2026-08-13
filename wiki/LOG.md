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


## [2026-05-05] bundle | brownfield as-is survey routing

Page edited:
- base-architecture-corollaries (added "Brownfield discovery and the
  as-is survey" subsection; tags extended with brownfield-discovery
  and as-is-survey; bundled_by extended to include project-setup so
  the §2.7 Discovery posture reaches the survey's reference material)

Bundles regenerated by `/vse-wiki-bundle` (full rebuild):
- project-setup gains the page (was: 16 pages, now: 17)
- architecture-design gets the new subsection inline
- vse-companion-overview, story-orchestrator, needs-and-requirements,
  attention-regime get the new subsection inline (no count change)
- All other bundles refresh timestamps only

INDEX rebuilt. Totals unchanged: 129 atomic pages across 11 layers,
21 bundles.

Companion methodology and skill changes land in the same PR
(feat/brownfield-as-is-survey).


## [2026-05-06] refactor | wiki stress-test follow-up

Findings from the dev_docs/stress-test-2026-05-05/ navigation
experiment surfaced three structural inconsistencies. Repairs
applied in this PR:

Pages edited (F1, parallel-layouts reconciliation):
- sysml2-canonical-model-layout (callout: methodology §8.3.1 is
  canonical for project paths; templated `{{sc}}_*` names describe
  the SysML 2.0 language convention only)
- sysml2-variant-organisation (callout: methodology §8.3.3 is
  canonical for variation paths)
- sysml2-namespace-hygiene (callout: methodology §8.3.4 is
  canonical for project file/folder names)
- sysml2-base-architecture-and-federation (callout: methodology
  §2 and §8.3.1)
- vse-canonical-project-layout (related extended)
- project-management-workflow (related extended)

Page added (F3, project-bootstrap synthesis):
- project-bootstrap-prerequisites (new, layer:
  project-structure). Synthesises the §10 PM.1 viewpoint and the
  §4.2 inputs viewpoint into one bootstrap-prerequisites page so
  end users do not have to discover both sides independently.
  Bundled by project-setup and project-audit.

Methodology spec edit (F2, hooks guide §2 table repair):
- iso-29110-hooks-guide.md §2 table: SR.O3 row now lists
  `pre-push` traceability integrity check explicitly, consistent
  with the implementation in §4.4.

Bundles regenerated by `/vse-wiki-bundle`:
- project-setup (was 17 pages, now 18 — gained
  project-bootstrap-prerequisites)
- project-audit (was 5 pages, now 6 — same gain)
- sysml2-model-structure (4 pages with callouts refreshed)

INDEX rebuilt. Totals: 130 atomic pages (was 129, +1 from
project-bootstrap-prerequisites) across 11 layers, 21 bundles.

The full experiment report and per-case scoring lives at
`dev_docs/stress-test-2026-05-05/round3/results/summary.md`
(gitignored; not shipped to installers).

## [2026-08-07] refactor | raw source filename normalisation

Sixty-two `raw:` values across forty-seven pages named files that do
not exist under `sources/`. They were tidied-up labels rather than
filenames, so the source-freshness rule in `/vse-wiki-lint` step 6
could never compare a raw file's mtime to a page's `updated:` date and
reported "raw source not present locally" instead. No page bodies were
touched, only frontmatter.

Mapping applied (count in parentheses):

- `Douglass_2016_Agile_Systems_Engineering.pdf` (14) to
  "Agile Systems Engineering.pdf"
- `ISO_IEC_TR_29110-5-6-2_2014.pdf` (10) to
  "ISOIEC TR 29110-5-6-22014.pdf"
- `Douglass_2021_Agile_MBSE_Cookbook.pdf` (8) to
  "Agile Model-Based Systems Engineering Cookbook_ Improve system
  development by applying proven recipes for effective agile systems
  engineering.pdf"
- `sensmetry_docs_2026-04` (6) to `null`. Web source, and the
  citations already carry URLs.
- `incose_handbook_4e.pdf` (5) to
  "INCOSE Systems Engineering Handbook 4e 2015 07.pdf"
- `galinier_sme_practices.pdf` (5) to
  "Galinier et al. - Systems Engineering Practices for Smal and
  Medium .pdf"
- `Galinier_SME_Practices_2023.pdf` (1) to the same Galinier filename
- `HSI_Primer_Vol1.pdf` (5) to "HSI Primer Vol. 1 v4.pdf"
- `INCOSE_VV_Guide_v1.pdf` (4) to `Guide_to_V-and-V_v1.pdf`
- `INCOSE_NeedsAndReqs_v1.pdf` (3) to `Guide_to_Needs_and_Reqts_v1.pdf`
- `ISO_IEC_29110_System_Software_Engineering.pdf` (1) to
  "ISOIEC TR 29110-5-6-22014.pdf". The page's own citation names
  ISO/IEC TR 29110-5-6-2:2014, so the ISO TR file is the true source.

Untouched because they were already exact: `sysmlv2.pdf` (46),
`2-OMG_Systems_Modeling_Language.pdf` (18), `kappe.pdf` (4), the
repo-relative `methodology/*.md` paths (23 across ten section files),
and the existing `null` entries (17).

Policy from here on: `raw:` is an exact filename under `sources/`, a
repo-relative path inside the plugin tree (the form the
methodology-derived pages use), or `null`. Nothing else. A label that merely describes the
source belongs in `citation:`, which is the field end users read.

## [2026-08-07] lint | pre-overhaul baseline

Full lint pass executed manually against `skills/vse-wiki-lint/SKILL.md`
steps 1 to 9, as the baseline for the v3.0.0 overhaul train. Report
written to `wiki/LINT_REPORT.md` (gitignored, not committed).

Pages scanned: 130. Bundles scanned: 21.
Summary: 0 ERROR, 136 WARN, 46 INFO.

Clean checks: no missing or malformed frontmatter, no slug or layer
mismatches, no unresolved wikilinks, no bundle without a consuming
skill, no bundle sourcing a missing page, no page claiming a
`bundled_by` entry absent from its bundle, no orphan pages, and no
remaining references to the deleted `knowledge/` directory.

WARN breakdown (136):
- 86 wikilinks present in a body but absent from the page's `related:`
  list. Metadata drift accumulated across ingest cycles. Repair belongs
  in an editorial sweep, not here.
- 50 schema-drift flags where a page's H2 headings do not match the
  template shape for its `type` (23 `concept`, 16 `process`, 11
  `pattern`). Detected by keyword heuristic, so this count is an upper
  bound and some pages have deliberately evolved away from the
  template.

INFO breakdown (46): all 46 are source-freshness flags, and all 46 cite
`sysmlv2.pdf`. These are **expected**. The 2026-06 release of the
specification was placed under `sources/` on 2026-08-06, while the
citing pages were last updated 2026-05-04 to 2026-05-06 against the
2026-04 release. The repagination and content-delta work that clears
them is scheduled separately. The flags are honest and should stay lit
until that work lands.

Zero "raw source not present locally" findings, down from 62 before
the normalisation recorded in the entry above. The staleness rule now
resolves for every page that names a raw file.

## [2026-08-07] restructure | wiki v3 data layer

The first half of the v3.0.0 wiki restructure. The contributor surface
migrates to the on-demand model. The runtime surface does not move in
this change, so installed behaviour is unchanged.

Schema. `wiki/CLAUDE.md` is rewritten around the navigable-wiki
contract. The runtime surface is `INDEX.md` plus per-skill routing
tables that name pages, and a skill reads a page on demand rather than
receiving a concatenated document. `bundles/` leaves the directory
layout. A new Routing tables section fixes the marker-block format, the
generation rules, the prohibition on hand edits inside the markers, and
the one-hop rule. The lint rule set, the ingest contract, and the
refactor contract are restated against those surfaces. The `bundle`
operation section becomes an `index` operation section.

Frontmatter. All 130 pages migrate. `bundled_by` becomes
`referenced_by` (required, may be empty). A required one-line `summary`
is added to every page, under 120 characters, single-sourcing both the
INDEX summary column and the routing-table "Read when" column. Drafts
came from each page's first body sentence. Eighty-two were hand-written
where the first sentence was a cross-reference, a fragment, a table
row, or did not survive compression. The five page-type templates under
`wiki/schema/` carry the same two changes.

The full `raw:` policy is now written into the schema, closing the
carry-over from the pre-overhaul hygiene work. `raw:` is optional per
source entry, and when present it is an exact filename under
`sources/`, a repo-relative path inside the plugin tree, or `null` for
web-only sources whose citations carry URLs.

Contents blocks. 106 of the 130 pages gain a `## Contents` list of
their H2 headings, per the mechanical rule: over 100 lines and three or
more H2 sections. The remaining 24 are all at or under 100 lines. Ten
insertions were checked by hand across layers.

Skills. `vse-wiki-bundle` becomes `vse-wiki-index`, with three
operations: regenerate `INDEX.md`, regenerate each consumer skill's
`wiki-routing` marker block from `referenced_by` and `summary`, and
verify contents blocks. The other three wiki skills and the two wiki
subagents drop their bundle vocabulary, and all four wiki skills drop
the executing `wiki/CLAUDE.md` tail in favour of the prose instruction
they already carried.

INDEX. Regenerated in the new format, with a navigation preamble and
per-layer tables carrying Slug, Title, Type, Summary, and Referenced
by. Totals match disk: 130 pages, 11 layers, 21 referencing skills.
Two consecutive runs with the generated-file timestamp pinned produce
a zero diff.

`wiki/bundles/` remains on disk with all 21 bundles, and the 21
consumer skills are untouched, including their embed tails. Both are
retired in the runtime flip that follows.

## [2026-08-07] lint | post-data-layer

Full lint pass executed manually against the rewritten rule set in
`skills/vse-wiki-lint/SKILL.md`, steps 1 to 10. Report written to
`wiki/LINT_REPORT.md` (gitignored, not committed).

Pages scanned: 130. Routing blocks scanned: 0.
Summary: 0 ERROR, 171 WARN, 90 INFO.

Rules exercised and clean: required frontmatter on every page
(including the new `summary` and `referenced_by`), slug and layer
agreement with the filesystem, summary length and single-line shape,
wikilink resolution, `raw:` resolution against the three legal forms,
orphan detection, and contents-block presence and ordering.

Rules not exercisable in this change, and why: the four routing
consistency rules (bidirectional membership, path resolution, sorted
order, and summary fidelity) evaluate over zero marker blocks, because
the consumer skills receive their blocks in the runtime flip. They pass
vacuously and prove nothing yet. They are exercised for the first time
in the flip.

WARN breakdown (171):
- 86 wikilinks present in a body but absent from the page's `related:`
  list. Unchanged from the pre-overhaul baseline. Repair belongs in an
  editorial sweep.
- 64 schema-drift flags where a page's H2 headings do not match the
  template shape for its `type`. Detected by keyword heuristic, so this
  is an upper bound.
- 21 consumer skills still carrying a `wiki/bundles/` embed tail. This
  is the intended state of this change. The tails and the bundles are
  removed together in the runtime flip, and this count going to zero is
  one of that change's acceptance conditions.

INFO breakdown (90):
- 46 source-freshness flags, all citing `sysmlv2.pdf`, unchanged from
  the baseline and expected until the 2026-06 repagination work lands.
- 23 `raw: null` entries, all web-only sources whose citations carry
  URLs. Legal under the policy now written into the schema.
- 21 skills named in some page's `referenced_by` that carry no routing
  block yet. Expected until the runtime flip.

Zero orphans and zero contradiction candidates.

## [2026-08-07] restructure | bundles retired

`wiki/bundles/` deleted, 21 generated bundle files plus `.gitkeep`,
1.1 MB. The directory was the runtime surface until the flip. Consumer
skills now carry generated `wiki-routing` blocks and read pages on
demand, so nothing concatenates pages any more and no artefact under
`wiki/` holds page prose. The `bundle` LOG tag is historical from this
point.

## [2026-08-07] lint | post-flip

Full rule set, no vacuous rules left. Pages scanned: 130. Routing blocks
scanned: 20, carrying 176 rows.

- ERROR: 0.
- WARN: 152. 86 wikilinks present in a body but absent from the page's
  `related:` list, and 64 schema-drift flags where a page's H2 headings
  do not match the template shape for its `type`. Both counts are
  unchanged from the pre-flip baseline and both belong to an editorial
  sweep. The remaining 2 are pages that qualify for a `## Contents`
  block and carry none (benefit-as-criterion, storymeta-lifecycle),
  carried over from the data-layer migration.
- INFO: 69. 46 source-freshness flags, all citing `sysmlv2.pdf`, and 23
  `raw: null` entries for web-only sources. Both legal and both
  unchanged.

Three finding classes that the pre-flip run reported have gone to zero:
21 consumer skills carrying a `wiki/bundles/` embed tail, 21 skills
named in a page's `referenced_by:` with no routing block, and every
reference to the retired bundle surface outside the lint detector.
Zero orphans and zero contradiction candidates, unchanged.

## [2026-08-07] index | post-flip resync

Pages indexed: 130 across 11 layers. Routing blocks regenerated: 20,
176 rows. Referencing skills: 20, down from 21 because
vse-companion-overview now carries a knowledge-base note rather than a
table. Run twice end to end. The second run produced a zero diff in
every skill body and a zero diff in `INDEX.md` below the generated-on
timestamp line, which is the idempotence condition the skill states.
ToC drift: 2 pages missing a qualifying `## Contents` block, reported
and not repaired, because contents blocks are page content.

## [2026-08-07] refactor | syside layer refresh to August 2026 state

Editorial sweep over the `syside/` layer, driven by the v3 overhaul
Track B scope. Every page in the layer carries a 2026-08 access date in
its citations and a bumped `updated:`. Every `raw:` in the layer stays
`null`, which is legal because the sources are Sensmetry web
documentation and each citation carries its URL.

Pages updated:

- syside-tooling-overview: rewritten around the renamed lineup (Syside
  Editor: SysML v2 Essential, Syside Pro Suite, Syside Cloud, Syside
  Derisker beta), reference release 0.10.3 of 23 July 2026, a legacy
  note recording that the open-source `sysml-2ls` was archived in
  October 2025 as "SysIDE Editor Legacy", and a dated roadmap section
  (Syside and Sysand v1.0 together in Q3 2026, MCP servers for both, a
  high-level Python API). Confidence lowered to `medium` with a
  Confidence note, because the Derisker beta and the roadmap are the
  two forward-looking sections.
- syside-project-configuration: largest rewrite. Three-level discovery
  (global `$XDG_CONFIG_HOME/syside/syside.toml`, project
  `syside.toml`, personal `syside.user.toml`), merge semantics
  including the `exclude` concatenation exception, the `.git` and
  `sysand-lock.toml` root markers, and the `[format]`, `[lint]`,
  `[lsp]`, and `[telemetry]` sections with all six per-rule lint
  severities named.
- syside-core-api: parser characteristics section added (agent-driven
  editing, real-time connection type checking), surface verified
  against 0.10.x.
- syside-model-modification: version-stability section added flagging
  the 0.9.0 breaking changes (Automator CLI, scalar handling,
  validation diagnostics).
- syside-expression-evaluation: requirement evaluation added (0.9.0).
- syside-vse-workflows: `syside check --stats` CI guidance, editable
  grid views, ReqIF round-trip, and the 2026-03 standard library
  added. Trimmed back under 300 lines while adding them.

Page authored:

- syside-sysand-package-management (new): Sysand v0.2.0, the
  `sysand.toml` project manifest and the KerML 10.3 `.project.json`
  and `.meta.json` interchange manifests, `sysand-lock.toml`, the
  command surface, KPAR interchange packages, the publisher-namespaced
  index at sysand.com, and the GitHub Action for CI publishing.
  `confidence: high`, because every feature listed has shipped.
  `referenced_by: [project-setup, sysml2-modelling]`.

Cross-links: tooling-overview and project-configuration both gained a
wikilink to the new page. The six existing pages had prose slug
references converted to wikilinks, matching the rest of the wiki.

Product-naming sweep in the same change: `SySiDE` normalised to
`Syside` across skills, agents, templates, and wiki prose, and the
layer label in `wiki/CLAUDE.md`. Eight pages outside the `syside/`
layer carry the renamed product in prose. Their `updated:` fields are
deliberately not bumped, because the edit is a branding
normalisation rather than a content revision, and bumping them would
suppress the source-freshness INFO that the sysmlv2 repagination cycle
depends on.

Routing resynced: project-setup, sysml2-metadata, sysml2-modelling.
INDEX regenerated. Totals move from 130 to 131 pages across 11 layers,
routed to by 20 skills.

## [2026-08-07] lint | post-syside-refresh

Full post-flip rule set. Pages scanned: 131. Routing blocks scanned:
20.

- ERROR: 0.
- WARN: 150, down from 152 at the post-flip baseline. Every finding is
  pre-existing editorial drift: wikilinks present in a body but absent
  from the page's `related:` list, and schema-drift flags where a
  page's H2 headings do not match the template shape for its `type`.
  One of those schema flags is in the refreshed layer
  (syside-vse-workflows is typed `pattern` and does not use the
  pattern template headings), and it predates this change.
- INFO: 73, up from 69. The increase is four `raw: null` entries from
  the new page and the second citation added to two refreshed pages.
  All are legal web-only sources whose citations carry URLs.

No finding in this run is attributable to the refresh. Zero orphans.
Contents blocks: zero drift across all 131 pages, including the
project-structure page whose "Syside configuration" H2 was renamed by
the sweep together with its Contents bullet.

## [2026-08-07] source-added | sysmlv2.pdf

Raw file replaced with the 2026-06 release of "The SysML v2 Book"
(Weilkiens and Molnár, MBSE4U), 457 PDF pages. Stub appended manually
because the file was modified outside Claude, so the
source-added-reminder hook did not fire. The book changelog (printed
page i) records new material in Section 18.2.2 (cross-subsetting),
Section 25.9 (event occurrences), Sections 26.8 and 26.9 (abstract
actions, actions in a context), Sections 28.5 and 28.6 (communicating
state machines, actions or states), an expanded Section 29.1
(messages), an updated Chapter 10 (certification), plus errata that
name package-level-usage clarifications and expanded explanations in
the Expressions chapter. Repagination resolved here. The content delta
is tracked under issue #54.

## [2026-08-07] refactor | sysmlv2.pdf repagination to the 2026-06 release

All 46 pages carrying `raw: sysmlv2.pdf` cited the 2026-04 release with
its printed page numbers. Every citation now names the 2026-06 release
and carries page numbers taken from that release.

Mapping approach. The shift is not an offset. Printed pages before
Chapter 25 move by up to four pages, Chapter 26 by twenty-five, Chapter
33 by forty-six, Chapters 36 and 37 by forty-seven, and Chapter 41 by
thirty-one, because the 2026-06 insertions sit at several points and
the errata rebalanced page breaks. Worse, the old citations were not
all in one numbering: Chapter 41 appeared as pages 291 to 297 on pages
touched by the earlier repagination and as pages 265 to 271 on pages
that sweep missed, both under the same 2026-04 label. Arithmetic from
the old numbers was therefore unsound, and the mapping was built from
the source instead.

The map is section-anchored. The PDF bookmark tree gives every chapter
and section in Chapters 13 to 41. Printed page equals PDF physical page
minus twenty-two, verified on chapter-opening and mid-chapter pages in
Chapters 26, 37, 41, and 25. Bookmark destinations are not reliable on
their own: fifteen section bookmarks in that range point one page before
the page that actually prints the heading, so every section start was
re-verified by locating its heading text in the extracted page text.
Section 25.9 (Event Occurrences) prints on page 161, not the 160 its
bookmark suggests.

Each citation was then re-anchored to the sections its page draws on,
and the new range is the extent of those sections. Sections added in
2026-06 are excluded, because the wiki pages do not yet cover them.
Sections merely expanded are included, because the cited material still
lives there. Citations naming a chapter with no page range changed only
their release label.

Section renumbering. The occurrence page cited "Sections 25.8, 25.9,
and 25.10". Inserting the new Section 25.9 pushed the old 25.9 and
25.10 down to 25.10 and 25.11. The citation now reads Sections 25.8,
25.10, and 25.11 at pages 159 to 160 and 162 to 164, and the three
in-text section references in the body were renumbered to match. No
Event Occurrences content was added, which belongs to issue #54.

Editorial spot-check. Ten of the 46 rewritten citations were checked by
extracting the new printed pages from the PDF and confirming the cited
chapter or section heading sits there: Chapter 13 at 55, Section 17.3 at
102, Chapter 25 at 148, Section 26.6 at 178, Chapter 28 at 207, Section
30.4 at 243, Section 33.1 at 279, Chapter 35 at 296, Chapter 37 at 306,
and Chapter 41 at 322. All ten passed.

Release labels in page bodies. Twenty-four body lines named the 2026-04
release. Statements about what the release leaves pending were each
re-checked against the 2026-06 PDF and now name 2026-06: Chapter 59,
Chapter 75, Chapter 84, Chapter 86, and Chapter 108 are still
placeholders reading "This chapter will be published in a later
release", Chapter 33 still has no dedicated verdict-semantics section,
and the semantics of termination are still not formally specified.
Novelty flags of the form "new in the 2026-04 release" were dropped,
because the material is no longer new relative to the edition the wiki
cites. Three pages outside the 46
(sysml2-syntax-structure, sysml2-structural-and-behavioural-semantics,
sysml2-domain-libraries-causation-geometry) carried the same flag in
prose and were cleaned up with them.

Two claims turned out to be false against 2026-06 and were corrected
rather than re-anchored. Chapter 27 (Calculations) is published at pages
203 to 206, and Section 33.2.1 (Trade Studies) is published at page 288.
Both were recorded as pending upstream material on
sysml2-expressions-constraints, sysml2-expression-patterns,
sysml2-variant-patterns, and sysml2-variations-overview. Those pages now
record the material as outstanding wiki work. Writing it in is content
scope and lands under issue #54.

The `updated:` discipline. Twenty-eight pages are bumped to 2026-08-07.
Their cited chapters are untouched by the book changelog, so the
repagination genuinely brings them level with the source and the
lint source-freshness INFO would be noise. Eighteen pages keep their old
`updated:` date: sixteen cite chapters the changelog marks as changed
(18, 25, 26, 28, 29, 30) or sit in the package-level-clarification
scope, and two more were found here to cite newly published material.
For all eighteen the wiki still lags the source, so the freshness INFO
has to stay live until issue #54 closes the gap. The three pages outside
the 46 are not bumped either, following the precedent set by the Syside
branding sweep: a wording normalisation is not a content revision.

Not covered here. Roughly 250 fine-grained in-text page pointers of the
form "(Ch 26, p 140)" across the same 46 pages still carry 2026-04
numbering. They were left alone deliberately. Only a minority sit in
chapters where a verified constant offset holds (13, 15, 34, 36, 37,
38, 39, and Sections 26.1 to 26.7). The rest fall in chapters the
2026-06 release restructured or expanded, where each pointer needs its
own content check against the PDF, and guessing would put wrong numbers
in front of readers. This is a separate work item.

Routing and INDEX untouched. Citations live in frontmatter `sources`,
never in `summary`, and no `summary` changed, so no routing block and no
INDEX row needed regenerating.

## [2026-08-07] lint | post-repagination

Full post-flip rule set. Pages scanned: 131. Routing blocks scanned: 20.

- ERROR: 0.
- WARN: 152, unchanged. The same rule set run against `main` before this
  change reports 152 as well, so the repagination introduced no new
  warning. Every finding remains pre-existing editorial drift: wikilinks
  present in a body but absent from the page's `related:` list, and
  schema-drift flags where a page's H2 headings do not match the
  template shape for its `type`.
- INFO: 54, down by 28 from the same rule set run against `main`. The
  drop is exactly the 28 pages whose `updated:` was bumped, each losing
  one `sysmlv2.pdf` source-freshness finding. No other finding changed,
  and no page lost a freshness signal for a source other than
  `sysmlv2.pdf`.

The 18 held-back pages still report the source-freshness INFO against
`sysmlv2.pdf`, which is the intended state until issue #54 lands the
2026-06 content delta.

## [2026-08-10] ingest | sysmlv2.pdf 2026-06 content delta (issue #54)

Layer: sysml2. The content half of the 2026-06 release upgrade. The
repagination entry above brought every citation to the new page
numbers. This entry brings the wiki level with what the release
actually changed.

Pages authored:

- sysml2-abstract-actions (new, Section 26.8)
- sysml2-actions-in-context (new, Sections 26.9 to 26.9.4)
- sysml2-actions-vs-states (new, Section 28.6)
- sysml2-event-occurrences (new, Section 25.9)

Pages updated, tier one (the new material and what it forces):

- sysml2-state-machines (Section 28.5 added, plus two corrections)
- sysml2-flows-and-messages (taxonomy and Messages rewritten from the
  expanded Section 29.1)
- sysml2-expressions-constraints (Chapter 27 placeholder replaced by
  the published treatment of calculations)
- sysml2-actions, sysml2-special-action-usages,
  sysml2-behaviour-patterns (pointers, the via-versus-to send routes,
  two patterns, two gotchas)

Pages updated, tier two and three:

- sysml2-specialisation-and-typing (Sections 18.2.1 and 18.2.2, the
  book added as a second source)
- sysml2-case-kinds, sysml2-case-patterns (verdict values, include
  declarations, the analysis-case example, trade studies)
- sysml2-expressions-overview, sysml2-sequences-and-structures,
  sysml2-functions-and-higher-order, sysml2-expression-patterns
- sysml2-syntax-features-and-attributes (package-level clarifications)
- sysml2-occurrence-context-and-variables, sysml2-cases-overview,
  sysml2-variations-overview, sysml2-variant-patterns

Corrected syntax that was previously wrong in front of readers. The
Tier 3 verification pass against Chapter 30 found six discrepancies,
four of them syntax the language does not have. The wiki taught `>>`
as the function operation chaining symbol, where the book uses `->`
and has no `>>` operator at all. It taught an arrow-lambda form
`{ in p : Part => p.mass }`, where a function literal declares its
parameters and then its body expression. It had the collect and
select operator notations shifted by one, so a documented "filter"
pattern would have collected Booleans. And it dropped the mandatory
parentheses around an indexing operand. All four are fixed on
sysml2-functions-and-higher-order, sysml2-expression-patterns,
sysml2-expressions-constraints, and sysml2-sequences-and-structures,
and each corrected page now states the fact plainly so the wrong form
is not reintroduced. Two smaller fixes: a false claim that reference
subsetting binds a constraint to its context, and `SubString` for
`Substring`.

In-body pointers. Every pointer of the form "(Ch 26, p 140)" on a
page this ingest touches is refreshed from the extracts, which cover
Chapters 18, 25, 26, 27, 28, 29, 30, and 33 completely with printed
page headers. Pointers into chapters outside that set, which means
Chapter 31 on sysml2-expressions-constraints and Chapter 15 on
sysml2-namespace-hygiene, stay with the separate work item recorded
in the repagination entry.

Freshness. All 18 pages the repagination held back are now verified
and bumped, so the `sysmlv2.pdf` source-freshness INFO count goes
from 18 to 0. That closes the state the post-repagination lint entry
recorded as intended until this issue.

Routing resynced: sysml2-behaviour (four new rows). INDEX
regenerated, 131 pages to 135. No `summary:` on an existing page
changed, so no other routing block moved. The 2026-08-07
`source-added | sysmlv2.pdf` stub is marked ingested by this entry.

## [2026-08-10] lint | post-ingest (issue #54)

Full rule set, run against the branch and against `main` at the merge
base so the delta is like for like. Pages scanned: 135 on the branch,
131 on `main`. Routing blocks scanned: 20 in both.

- **ERROR: 0** on both sides.
- **WARN: 242** on the branch against 240 on `main`. The movement is
  four new schema-drift findings, one per new page, against two
  wikilink-related findings resolved by adding the linked slugs to
  the pages' `related:` lists.
- **INFO: 9** on the branch against 27 on `main`. The drop of 18 is
  exactly the `sysmlv2.pdf` source-freshness findings, which reach
  zero. The nine that remain are all `methodology/*.md` sources on
  methodology-layer pages and are untouched by this ingest.

Reading the schema-drift count. This rule fires on every page in the
wiki, on both sides, because the templates under `wiki/schema/`
document what each page type is for in prose rather than prescribing
a heading set. Its count therefore tracks the page count and carries
no signal about the pages this ingest touched. The absolute WARN
figure here is not comparable with the 152 recorded in the
post-repagination entry, which came from a differently calibrated
run of the same rule.

The four new pages carry no finding other than that global
schema-drift one. Zero broken wikilinks, zero contents-block drift
across all 135 pages, zero orphans, and no page lost or gained a
frontmatter finding.

## [2026-08-13] ingest | sysmod.pdf

Layer: sysmod (new layer, schema row and directory-tree entry added in
the same PR, per the layer rule in `wiki/CLAUDE.md`).

Pages authored:

- sysmod-toolbox-anatomy (new)
- sysmod-model-purpose-levels (new)
- sysmod-base-architecture-source (new)
- sysmod-system-context-source (new)
- sysmod-problem-statement-and-objectives (new)
- sysmod-stakeholder-identification (new)
- sysmod-zigzag-pattern (new)
- sysmod-architecture-kinds-and-coupling (new)
- sysmod-functional-analysis-chain (new)
- sysmod-iso15288-landscape (new)
- sysmod-test-modelling (new)

Eleven pages rather than the ten the decomposition proposed. The
eleventh, `sysmod-test-modelling`, was added at the engineer's
direction over the proposal's recommendation to leave the Test Case
and Test Architecture material out of this cycle. It covers the
verdict-returning test behaviour, the Model Test Case, and the Test
Architecture as an architecture kind, and it routes to
verification-validation.

Three candidates stay rejected, with the reasons recorded in the
decomposition proposal. Proxy against full ports is resolved by SysML
v2 having one port concept. Variant modelling is left wholly to the
VAMOS cycle (issue #56), which also carries the `raw: vamos.pdf`
correction on `sysml2-variant-organisation`. Risks stay covered by
`sysml2-model-cm-and-risks` and `ambse-risk-and-metrics`, with the
proxy-element idea preserved as one section of
`sysmod-toolbox-anatomy`.

Related-link touchpoints: 13 existing pages updated. Two of them
(`base-architecture-corollaries`, `system-context-completeness`) also
carry a body one-liner pointing at the source account.
`sysml2-variant-organisation` was listed as a touchpoint and is
deliberately unchanged, because its Weilkiens cross-links belong to
the VAMOS cycle. `benefit-as-criterion` gained a contents block
because the `related:` line took it past 100 lines.

Routing resynced: project-setup (+4 rows), architecture-design (+4),
needs-and-requirements (+5), project-audit (+1),
verification-validation (+1). The review restored the lens design from
the runtime flip: `vse-companion-overview` routes to skills, not
pages, so it carries no marker block, and the three source-level
orientation pages are homed on project-setup and project-audit. The
distinct referencing-skill count stays at 20.

INDEX regenerated: 135 pages and 11 layers to 146 pages and 12 layers.

There was no unresolved `source-added` stub for `sysmod.pdf` in this
log, so nothing is marked ingested by this entry.

## [2026-08-13] lint | post-ingest (issue #55)

Full rule set, run against the branch and against `main` at the merge
base so the delta is like for like. Pages scanned: 146 on the branch,
135 on `main`. Routing blocks scanned: 21 on the branch, 20 on `main`.

- **ERROR: 0** on both sides.
- **WARN: 231** on the branch against 220 on `main`. The movement is
  exactly eleven new schema-drift findings, one per new page. The 84
  wikilink findings and the single stale contents block are identical
  on both sides.
- **INFO: 0** on both sides.

Reading the schema-drift count. This rule fires on every page in the
wiki, on both sides, because the templates under `wiki/schema/`
document what each page type is for in prose rather than prescribing a
heading set. Its count therefore tracks the page count and carries no
signal about the pages this ingest touched.

The eleven new pages carry no finding other than that global one. Zero
broken wikilinks, zero contents-block drift across all 146 pages, zero
orphans, and no existing page gained a frontmatter finding. Routing
bidirectional consistency holds in both directions, and all 199
routing-row paths resolve.

One observation for a future editorial sweep, present on `main` and
not introduced here: `sysml2-variation-definitions` names
`sysml2-quick-ref-keywords` in its `related:` list and no page carries
that slug. The documented rule set checks wikilink resolution rather
than `related:` resolution, so it is not a finding at any severity.

## [2026-08-13] ingest | vamos.pdf

Layer: sysmod (existing, the schema row already names VAMOS alongside
SYSMOD 3rd edition and The New Engineering Game).

Pages authored:

- sysmod-vamos-concepts (new)
- sysmod-vamos-method (new)
- sysmod-vamos-feature-trees (new)
- sysmod-vamos-configurations (new)
- sysmod-vamos-binding-and-constraints (new)

The `sysmod-vamos-` prefix marks the source family inside a layer that
now holds three Weilkiens sources, and keeps the method pages distinct
from the `sysml2-variant-` syntax family.

One candidate folded: the chapter 4 survey of FODA, CVL, and OVM
becomes one section of `sysmod-vamos-concepts` rather than a page of
its own. Reasons are in the decomposition proposal, as are the two
candidates that stay rejected, the sample-project narrative and the
proxy-port and diagram-adornment asides.

Seam fix: `sysml2-variant-organisation` had `raw: null` on its 2016
Weilkiens citation. Set to `vamos.pdf`, with three VAMOS cross-links
added to `related:` and one body pointer at the end of the opening
paragraph. `referenced_by:` untouched.

Related-link touchpoints: 5 further existing pages updated
(`sysml2-variations-overview`, `sysml2-variant-configuration`,
`sysml2-variant-patterns`, `sysml2-vse-library-metadata`,
`sysmod-toolbox-anatomy`). Two of them also carry a body one-liner.

Routing resynced: sysml2-variants (+5 rows, 4 to 9),
architecture-design (+1, 15 to 16), sysml2-model-structure (+1, 5
to 6). INDEX regenerated: 146 pages to 151.

Correction in the INDEX totals line. The referencing-skills count moves
from 21 to 20, and the movement is a correction rather than a loss. The
header had been left at 21 when the lens-design fix in #73 removed the
routing block from `vse-companion-overview`, while the table body below
it already listed 20 distinct skills. Regeneration from frontmatter,
which is the rule the schema states, now agrees with the body.

## [2026-08-13] lint | post-ingest (issue #56)

Full rule set against the branch. Pages scanned: 151. Routing blocks
scanned: 20, excluding the marker occurrences inside inline code spans
in `vse-wiki-index` and `vse-wiki-lint`, which are documentation.

- **ERROR: 0.** Frontmatter integrity, routing bidirectionality in both
  directions across 204 rows, path resolution, sorted order, summary
  fidelity, and wikilink resolution all hold.
- **WARN: 236.** The movement from the previous run is exactly five new
  schema-drift findings, one per new page. That rule fires on every page
  in the wiki because the templates under `wiki/schema/` describe each
  page type in prose rather than prescribing a heading set, so its count
  tracks the page count and carries no signal about this ingest. The 84
  wikilink findings and the single stale contents block are unchanged
  from `main`, so none of them comes from this cycle.
- **INFO: 0.** No orphans, no empty tag lists, no date inversions, and
  no source file newer than its page by more than 14 days.

The five new pages carry no finding other than the global schema-drift
one. Each lists every slug it links, so the stale-metadata rule stays
silent on all five.

## [2026-08-13] ingest | new-engineering-game.pdf

Layer: sysmod (existing, the schema row already names The New
Engineering Game alongside SYSMOD 3rd edition and VAMOS).

Pages authored:

- sysmod-neg-complexity-and-dynamics (new)
- sysmod-neg-organisational-tools (new)
- sysmod-neg-human-dimension (new)
- sysmod-neg-why-mbe (new)

The `sysmod-neg-` prefix marks the third Weilkiens source family in
the layer, following the `sysmod-vamos-` precedent.

This is the most narrative of the three Weilkiens sources, so roughly
half the extract material is folded or rejected rather than carried.
The industrial-revolutions narrative and the globalisation section
fold into one orientation paragraph on page 1. The Business Model
Canvas, the Value Proposition Canvas, and the Business Model Navigator
are rejected as outside the wiki's engineering scope. SYSMOD
Essentials and the FAS restatement are rejected as duplicates of the
existing SYSMOD ingest. REThink 4.0 was evaluated as a standalone page
and folded into page 4 instead, where it does the why-MBE work
directly. Reasons are in the decomposition proposal.

Three pages carry `confidence: medium` with a Confidence note in the
body, because the fourth-industrial-revolution framing, the New Work
observations, and the ten PLM4MBSE theses are forecast or advocacy
rather than settled practice. Page 2 is `high`.

Two findings are recorded on the pages rather than buried. The de Weck
First Law equation does not survive text extraction from the source in
a trustworthy form, so page 1 carries the conservation idea in prose
only and says so. The source's two complexity definitions and the
plugin's own option-count formalisation are three different
measurements, so page 1 carries a bridging note rather than a
unification.

One tension is stated rather than smoothed. Wohland's "find the right
person instead of the right process", quoted by the source, is
person-first where PHAS-EAI H7 is environment-first. Page 3 states the
reconciliation: the two prescriptions address different scopes, the
person for the surprise in front of you and the designed reserve that
reduces how often a surprise needs one, and the book's own §3.8 and
§3.9 already argue the second.

Second-source seams: `sysmod-base-architecture-source` gains the
record-player worked example, the Conway propagation sentence, and a
§4.6 citation. `sysmod-zigzag-pattern` gains a §4.7 citation only, the
body being unchanged because the source reuses the identical worked
example. `sysmod-toolbox-anatomy` gains one SYSMOD Essentials sentence
in its tailoring section plus a §4.9 citation. The §4.10 functional
architecture restatement takes nothing, being a duplicate of
`sysmod-architecture-kinds-and-coupling`.

Touchpoints: `sysmod-problem-statement-and-objectives` gains the BMM
goal-against-objective paragraph in its System Objectives section, the
six Design Thinking step names in its Design Thinking bullet, and a
§4.5 and §4.8 citation. The Business Motivation Model check the brief
required was performed and the cluster stays rejected as pages. All
three phas-eai pages carry the new human-dimension page in `related:`,
and `phas-eai-overview` also carries a one-line pointer in its
designed-cognitive-reserve section. `ambse-requirements-as-models`,
`ambse-principles`, and `sysmod-model-purpose-levels` are
metadata-only. `referenced_by:` is untouched on every existing page.

No `source-added` stub existed for this file, so nothing was resolved.

Routing resynced: project-setup (+3 rows, 23 to 26), attention-regime
(+1, 5 to 6). Routing rows 204 to 208. project-audit was evaluated as
a third routing home and takes nothing, because none of the four pages
is audit material. `vse-companion-overview` stays block-free per the
#73 lens-design rule, which this ingest honours by homing every page
elsewhere.

INDEX regenerated: 151 pages to 155. Layers stay 12 and referencing
skills stay 20.

## [2026-08-13] lint | post-ingest (issue #57)

Full rule set against the branch. Pages scanned: 155. Routing blocks
scanned: 20, excluding the marker occurrences inside fenced blocks and
inline code spans in `vse-wiki-index` and `vse-wiki-lint`, which are
documentation.

- **ERROR: 0.** Frontmatter integrity, routing bidirectionality in
  both directions across 208 rows, path resolution, sorted order,
  summary fidelity, and wikilink resolution all hold.
- **WARN: 240.** The movement from the previous run is exactly four
  new schema-drift findings, one per new page. That rule fires on
  every page in the wiki because the templates under `wiki/schema/`
  describe each page type in prose rather than prescribing a heading
  set, so its count tracks the page count and carries no signal about
  this ingest. The 84 wikilink findings and the single stale contents
  block are unchanged from `main`, so none of them comes from this
  cycle.
- **INFO: 30.** Twenty-six are `raw: null` observations on web-sourced
  syside and sysml2 pages, whose citations carry the URL as the schema
  requires. Four are source-freshness observations on
  methodology-derived pages whose `raw:` file under `methodology/` has
  been edited since the page was last updated. All thirty are
  pre-existing and none touches a page from this ingest. No orphans,
  no empty tag lists, and no date inversions.

The four new pages carry no finding other than the global schema-drift
one. Each lists every slug it links, so the stale-metadata rule stays
silent on all four.

## [2026-08-13] ingest | Paper V - Systems Engineering - 2026 - Georgsen - Navigating Uncertainty  Guiding Attention in Purposeful Human Activity Systems.pdf

Layer: phas-eai (existing, the schema row names PHAS-EAI framework
papers alongside kappe.pdf).

Pages authored:

- phas-eai-active-inference-model (new)
- phas-eai-designing-attention-regimes (new)
- phas-eai-overview (updated)
- phas-eai-de-requirements (updated)
- phas-eai-levers-and-evidence (updated)
- sysmod-neg-human-dimension (updated)

The concept page carries the formal model, which supplies definitions
for `omega`, `g(.)`, and `Phi`, the three symbols the R3 model link
names and the wiki did not define anywhere. The process page carries
the five inquiry questions and the two-year VSE security case, at
`confidence: medium` because the source records that its design does
not isolate causal effect against a process-only baseline.

Three candidates stay rejected: a PHAS-lineage page, a case-study-only
page, and a precision-and-salience page. The first is intellectual
history the plugin does not need to operate, and the other two would
force a two-hop read the schema forbids.

Second-source updates. `phas-eai-overview` gains the Paper V entry, the
precision account of salience, the Ramstead, Veissiere and Kirmayer
provenance for the two constructs, and the formal reading of niche
construction. `phas-eai-de-requirements` gains the entry with pointers
from R3 and R4. `phas-eai-levers-and-evidence` gains the entry with a
worked instance under H9. `sysmod-neg-human-dimension` takes no source
entry, its sources being Weilkiens, and gains one pointer in its
regimes bullet. `referenced_by:` is untouched on every existing page.

No `source-added` stub existed for this file, so nothing was resolved.

Routing resynced: attention-regime (+2 rows for this source, 6 to 8).

## [2026-08-13] ingest | Paper IV - 5674-Article Text-21352-1-10-20231101.pdf

Layer: phas-eai (existing).

Pages authored:

- phas-eai-llm-peer-review (new)
- phas-eai-de-requirements (updated)
- phas-eai-levers-and-evidence (updated)
- sysmod-neg-human-dimension (updated)

The page is the case evidence behind the R2 premise, which the wiki
previously held as one line and two case-support letters. It is a
`pattern` page at `confidence: medium`, and it states the dated-evidence
limit up front. The 2023 model-specific findings, the regular
expression, mathematics, and JSON weaknesses and the privacy landscape
of that year, are excluded as stale. What is kept concerns the shape of
the interaction rather than model capability: the mentor effect, the
divergence caution on numerical scores, the mechanism behind the quality
gain, and the workflow shape.

Rejected second source: adding this file to the iso29110 layer for its
valve-liability anecdote. The anecdote belongs to Laporte and Munoz
(2021), which is the source to ingest if that ground is wanted.

Second-source updates. `phas-eai-de-requirements` gains the entry and a
sentence under R2. `phas-eai-levers-and-evidence` gains the entry and a
sentence under H7. `sysmod-neg-human-dimension` gains one pointer in its
reserve bullet, with no source entry.

No `source-added` stub existed for this file, so nothing was resolved.

Routing resynced: attention-regime (+1 row, 8 to 9),
needs-and-requirements (+1 row, 25 to 26). The second routing home is
justified by the
divergence caution and the rubric, which shape how that skill should
present LLM quality scores.

## [2026-08-13] index | routing resync

Pages indexed: 158. Routing blocks regenerated: 2. Routing rows 208 to
212. Layers stay 12 and referencing skills stay 20. ToC drift: 0.
