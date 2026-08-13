---
title: "Why model-based engineering: the digitalisation rationale"
slug: sysmod-neg-why-mbe
type: concept
layer: sysmod
summary: "The industry case for MBE: the model criterion, ten PLM4MBSE theses, REThink 4.0 stages, and query-driven modelling"
tags: [neg, mbe, plm, rethink-4-0, query-driven-modelling, agile, lean, requirements-as-models]
sources:
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §4.11 (Model-Based Engineering)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §4.12 (REThink 4.0)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §4.13 (Agile and Lean Systems Engineering)"
    raw: new-engineering-game.pdf
related:
  - ambse-requirements-as-models
  - ambse-principles
  - sysmod-model-purpose-levels
  - methodology-overview
  - sysmod-neg-complexity-and-dynamics
confidence: medium
created: 2026-08-13
updated: 2026-08-13
referenced_by: [project-setup]
---

# Why model-based engineering: the digitalisation rationale

## Contents

- MBE as MBSE plus PLM
- What makes something a model
- Ten theses about MBE and PLM
- The document-based failure mode
- Over-modelling and query-driven modelling
- REThink 4.0
- Agile and lean for product engineering
- Where the plugin stands
- See also

Confidence note: this page is `medium` rather than `high` because two
of its sections carry advocacy rather than settled fact. The ten
theses, including the claim of a three-to-one return on investment,
come from a position paper written to argue a case, and the source
reproduces them as theses rather than as findings. The INCOSE Vision
2020 and Vision 2025 statements are predictions about the discipline,
quoted here because they show what the community expected, not because
the expectation has been verified. The model criterion, the REThink 4.0
stages, and the query-driven modelling procedure are definitional or
procedural and are firmer.

## MBE as MBSE plus PLM

The source distinguishes two acronyms that differ by one letter.
Model-Based Systems Engineering is the formalised use of models in
support of systems engineering. Model-Based Engineering, without the
"systems", is defined by the PLM4MBSE position paper as the
combination of lifecycle-spanning management of product data, that is
Product Lifecycle Management, with the formal model-based description
of systems.

The source treats the merge as the point. PLM and MBSE have separate
roots, PLM originating in computer-aided design and acquiring its
holistic ambition in the 1990s, and the two have been converging for
some years. The argument for needing both is that a consistent,
holistic, connected model of the product is the only practical
foundation for managing dependencies between engineering artefacts
under the complexity and dynamics described on
[[sysmod-neg-complexity-and-dynamics]].

## What makes something a model

The source asks a question that is more awkward than it looks: which
criterion makes a SysML model a model and a spreadsheet not one? It
rejects two popular answers before offering its own.

- **Abstraction fails.** "A model is an abstraction of something" does
  not exclude a text document, because a descriptive text is also an
  abstraction of the thing it describes.
- **Separation of repository and views fails.** Office documents
  separate stored data from its representation just as a modelling tool
  does. A spreadsheet's chart types are views on worksheet data in
  exactly the sense that several SysML diagrams can show one repository
  element.

The working criterion the source proposes is about vocabulary: the
semantics and the abstract syntax of the modelling language cover the
concepts of the domain. Requirements and architecture blocks are
concepts of the engineering domain and are part of SysML. An office
document language carries headlines, paragraphs, and bold type, so an
office document is a model of an office document and not a model of an
engineered system. The consequence the source draws is practical.
Only a language that covers the domain concepts enables useful analysis
and visualisation of the model.

## Ten theses about MBE and PLM

The PLM4MBSE paper postulates ten theses, reproduced here in condensed
form and explicitly attributed as a position paper rather than as
measured results.

| # | Thesis |
|---|---|
| 1 | MBE is the enabler for the Internet of Things and Industry 4.0 |
| 2 | Product liability and functional safety regulation drive MBE |
| 3 | Future PLM systems need a holistic view of a product as a multidisciplinary system |
| 4 | Early design decisions must be logically and functionally validated using system models |
| 5 | MBSE results must be available across the whole product lifecycle |
| 6 | MBE requires models with meaning |
| 7 | The MBE toolchain must rely on technology-independent standards |
| 8 | Rising product and production complexity demands new processes, methods, and tools |
| 9 | MBE requires changes in organisation, methodology, technology, and education |
| 10 | Investments in MBE can deliver a return on investment of three to one |

Thesis 10 is the one to handle with care. It is a claim from an
advocacy document with no measurement procedure attached, and it should
be quoted as such if it is quoted at all.

## The document-based failure mode

The source's argument against document-based specification is a single
image: "doing systems engineering with documents is like doing
mechanical engineering with MS Paint". What you see is
what you get, there is no way to process the information
automatically, and there is no way to create specific views for
different stakeholders.

Two INCOSE statements are quoted in support. Vision 2020 held that the
future of systems engineering can in many respects be said to be
model-based, driven by the continued evolution of complex, intelligent,
global systems that exceed the ability of the humans who design them to
comprehend and control every aspect. Vision 2025 states more briefly
that model-based systems engineering will become the norm.

## Over-modelling and query-driven modelling

The source names the opposite failure with equal directness. A typical
modelling mistake is the tendency to model too many details, and
over-modelling is wasted effort.

Its answer to "what should be modelled?" is to start from the other
end, by analogy with test-driven development. Query-Driven Modelling
runs as follows.

1. Define the queries and views the stakeholders need, for example a
   table, a document, a diagram, or a traceability matrix.
2. Run the query and view generators. The queries fail and the views
   come out empty, which is the point: it proves the generation scripts
   work before any model data exists.
3. Create the model data according to the project's modelling
   methodology.
4. Run the queries and generate the views again, and repeat step 3
   until the generated views match the specification.
5. Refactor before adding further views. Adapt the model structure,
   move common elements into a model library, and remove unused
   elements, because adding to a clean model is much cheaper.

Alongside this the source names Open Services for Lifecycle
Collaboration, a set of specifications for integrating tools and their
data over standard internet technologies, as the promising direction
for a tool ecosystem, on the grounds that no single method or tool
covers every aspect of an engineering project.

## REThink 4.0

REThink 4.0 is the source's requirements paradigm, and the number four
refers to the fourth stage of a ladder of requirement representations.

| Stage | Representation | Weakness the next stage answers |
|---|---|---|
| 1 | Plain text | Easy to read, imprecise, easily misunderstood, cross-links hard to manage |
| 2 | Structured text, for example tables | Structure helps, the content is still natural language |
| 3 | Textual requirements embedded in a model or a requirements management tool | The core of the requirement is still text |
| 4 | Model elements are themselves the requirements | None. This is the target state |

At stage 4 the requirement attributes, such as identifier, priority,
and obligation, are assigned to the model element directly, and an
explanatory text statement may be added where it helps. A purely
textual specification document can still be generated, as a view of the
master data held in the model.

The source's demonstration is worth reproducing because it is
falsifiable. A SysML activity diagram specifies the execution order of
four tasks A, B, C, and D. The equivalent sentence reads: first A, then
B and C in a random order, whereas B is optional, and finally do D. The
source reports that when readers were given the sentence first, some
of them interpreted the execution order differently from one another,
which did not happen with the model-based specification. The
interpretation spread is the cost that stage 4 removes.

One caveat travels with the paradigm and must not be dropped. The
recommendation is not to abandon textual requirements. Modelled
requirements are used where they make sense, and a requirement that is
more effectively specified in pure text should be specified that way.

## Agile and lean for product engineering

The source's closing move is to insist that model-based engineering be
performed agilely and leanly. This section is deliberately a stub,
because the material is already covered in the wiki from the AMBSE
sources and only its three additions are specific to this book.

- **The manifesto is tweaked, not replaced.** The simplest adaptation
  of the Agile Manifesto outside software is to replace the word
  software with solutions, so that working software over comprehensive
  documentation becomes working solutions over comprehensive
  documentation. The source stresses that "over" does not mean
  "instead".
- **Four values specific to product engineering.** The Foundation for
  Complex Systems Engineering, written by the author with Arie van
  Bennekum, a co-author of the Agile Manifesto, and others, adds
  multifunctional teams over engineering silos, focus on purpose over
  focus on requirements, empowered teams over tasked individuals, and
  early learning over late failures.
- **Six lean principles.** Lean thinking adds value for the customer
  while removing waste, and the six principles are value, map the value
  stream, flow, pull, perfection, and respect for people.

## Where the plugin stands

The plugin already mandates model-first working in SysML v2, so this
page is rationale rather than process. Nothing here changes what a
project does. What it supplies is the independent industry-side
argument for why the plugin is built the way it is, which is useful
when the requirement has to be justified to somebody outside the
project. Three complement notes.

- **Two postures on requirements text.** Douglass keeps a dual
  representation in which text explains why and models specify what,
  as recorded on [[ambse-requirements-as-models]]. REThink stage 4 is
  model-first, with explanatory text as an option rather than a
  counterpart. The difference is one of emphasis, and both sources
  agree that a requirement better expressed in prose should stay in
  prose.
- **Two value sets, one direction.** The Foundation for Complex Systems
  Engineering values sit beside the five AMBSE principles on
  [[ambse-principles]] rather than competing with them. Focus on
  purpose over focus on requirements is the closest thing in this
  source to the plugin's story benefit clause.
- **Query-driven modelling answers "how much".** The plugin's own
  answer to how much to model is fixed by the methodology, and
  [[methodology-overview]] states it. Query-Driven Modelling is a
  procedure for deciding what to model at any of the three SYSMOD
  purpose levels on [[sysmod-model-purpose-levels]], which makes it a
  useful discipline for peripheral areas where a project has room to
  choose.

## See also

- [[ambse-requirements-as-models]] for the AMBSE posture on
  requirements as model elements.
- [[ambse-principles]] for the five AMBSE principles and the modelling
  rules.
- [[sysmod-model-purpose-levels]] for the three modelling-purpose
  levels this rationale sits above.
- [[methodology-overview]] for the plugin's own position on models as
  the primary engineering artefact.
- [[sysmod-neg-complexity-and-dynamics]] for the pressures this
  rationale answers.
