---
title: "Designing regimes of attention: inquiry questions and case evidence"
slug: phas-eai-designing-attention-regimes
type: process
layer: phas-eai
summary: Five inquiry questions for designing regimes of attention, with a worked VSE security case and quantified outcomes
tags: [phas-eai, regimes-of-attention, patterned-practices, inquiry-questions, case-study, security]
sources:
  - citation: "Georgsen, R. E. (2026). Navigating Uncertainty: Guiding Attention in Purposeful Human Activity Systems. Systems Engineering. https://doi.org/10.1002/sys.70041"
    raw: "Paper V - Systems Engineering - 2026 - Georgsen - Navigating Uncertainty  Guiding Attention in Purposeful Human Activity Systems.pdf"
related:
  - phas-eai-overview
  - phas-eai-de-requirements
  - phas-eai-levers-and-evidence
  - phas-eai-active-inference-model
  - sysmod-neg-human-dimension
confidence: medium
created: 2026-08-13
updated: 2026-08-13
referenced_by: [attention-regime]
---

# Designing regimes of attention: inquiry questions and case evidence

## Contents

- Goal
- Preconditions
- Step 1: which signals the team must receive
- Step 2: how people meet the signals
- Step 3: which practices sustain attention
- Step 4: who finds the signals meaningful
- Step 5: what counts as success
- Postconditions and work products
- Failure modes
- How the plugin plays the same two roles
- See also

Confidence note: this page sits at `medium` rather than `high` because the
outcome evidence comes from a single participatory study of one team over two
years, and the source records its own limit plainly, that "the study design
does not isolate causal effect against a counterfactual process-only
baseline". The design procedure is reported at full fidelity and can be
followed as written. The numbers attached to it are one team's results and
carry that limitation with them.

## Goal

Design a Regime of Attention, together with the Patterned Practices that
sustain it, for one named dependability concern. A Regime of Attention is the
set of environmental features, such as social cues, physical arrangements, and
digital interfaces, that steer focus towards the information most useful for
reducing uncertainty. Patterned Practices are the regular, often ritualised
interactions with those features, through which a team internalises the
pattern and reaches shared intention. [[phas-eai-overview]] defines both
constructs and the four mechanisms a regime works through.

Both constructs are re-purposed from Ramstead, Veissière and Kirmayer (2016),
where they describe how cultural affordances scaffold local worlds, and the
source adopts them as prescriptive design tools rather than descriptive
categories. The five questions follow the inquiry-question format
Calvo-Amodio uses for the PHAS framework, with different questions reflecting
a different focus. The underlying claim is that attention, treated as a form
of action, is drawn to surprising input, and that a signal's salience is set
by its estimated precision, that is, its signal-to-noise ratio. Raising the
precision of the signals that matter is therefore the lever, and
[[phas-eai-active-inference-model]] carries the formal account.

## Preconditions

- A named concern that produces observable signals, rather than a general
  aspiration.
- A team with the authority to modify its own working environment, physical
  and digital.
- Agreement on who owns the concern and who acts on the signals.

The worked example throughout is the source's case study, a nine-person VSE
developing outdoor building and facility automation with remote access over 4G
modems. The company had suffered repeated security breaches in which attackers
used the modems to send spam, depleting customer data quotas and locking users
out, with operational, reputational, and financial losses. It lacked security
expertise and the means to hire it.

## Step 1: which signals the team must receive

Ask what information the team needs to reach the goal, whether it leaves the
team informed enough to decide, and whether it is reliable across contexts.

The case team needed timely, actionable information about vulnerabilities in
its own software. The inquiry led to Dependabot, a free service that scans
repositories continuously and proposes fixes. Where a fix exists, unit tests
are re-run against the patched code and the engineer sees a full test report
before anything reaches the main code base. The service is reachable through
the repository website and the GitHub API, and supplies CVSS v4 severity
metrics with links to the CWE and CVE entries, so an engineer can judge
severity and choose a mitigation even when no compatible fix exists.

## Step 2: how people meet the signals

Ask what patterns people use to engage with those inputs, how those patterns
reduce uncertainty, and whether the interaction is standardised or adaptable.

The team judged that not everyone would naturally attend to security alerts,
so it made them unavoidable instead, connecting a smart bulb to the GitHub
API. The bulb glows orange for low-severity issues and issues in development,
and blinks red for high-severity vulnerabilities in production. Email
notifications, alarm logs, and the platform's own web alerts were rejected for
one reason, that each requires proactive engagement and competes for attention
in a cluttered digital environment where critical signals are hard to separate
from background noise. The bulb acts as a salient shared sensor in the
physical workspace, capturing attention without conscious effort.

## Step 3: which practices sustain attention

Ask how the regime is embedded in the environment, which social and cultural
mechanisms reinforce it, and how the practices evolve to stay effective.

The team adopted serious games, which are games designed to entertain while
meeting an educational or organisational objective. It began playing Elevation
of Privilege, a card game for collaborative threat modelling. Regular play let
the team practise identifying and mitigating threats, embedded security
awareness in its culture, and doubled as training.

## Step 4: who finds the signals meaningful

Ask which stakeholders regard the signals and practices as significant, what
value they take from them, and how the signals relate to broader system goals.

The team found that the visibility the bulb provided mattered beyond the
developers. Its state gave management and non-technical staff an immediate
reading of the security health of the system, which aligned the whole company
behind prompt remediation and made the interventions more durable.

## Step 5: what counts as success

Ask what the criteria for success are, how the team will know the outcomes
have been achieved, and what balance of effort and outcome makes the process
worth running.

The team settled on three criteria: fewer unresolved high-severity
vulnerabilities, timely response to alerts, and improved performance in the
threat-modelling game. Over two years the automated system detected 90
vulnerabilities across four repositories. Five needed an engineer to
intervene, and two remained unfixed because of dependency constraints. All 88
fixable issues were patched within 24 hours of their CVE being listed
publicly, against a background of 40,009 CVEs published during 2024, an
average of 108 each day.

## Postconditions and work products

- A named signal source, with severity metrics an engineer can act on.
- A salient shared display that requires no polling.
- At least one practice with a cadence, owned by the team.
- Written success criteria with a way of measuring them.

## Failure modes

- Signals routed into channels that compete for attention. Recovery is to move
  the signal into a shared, low-effort display.
- Practices that decay once the meaning is held only by the technical team.
  Recovery is Step 4, making the value legible to the stakeholders who fund
  the work.
- Success criteria written once and never revisited, so drift is not visible.
  Recovery is to re-run Step 5 on a fixed cadence.
- Treating the case numbers as a causal warrant. The limitation in the
  confidence note above applies to any claim of effect size.

## How the plugin plays the same two roles

The plugin implements both halves of the pattern. Its hooks and session-start
context injection occupy the position of the smart bulb, surfacing what needs
attention without the engineer going to look for it. Its phase-scoped skills
occupy the position of the Patterned Practice. R4 in
[[phas-eai-de-requirements]] names that mechanism as a design requirement, and
the case is the published worked example of raising the methods and tools
curve without a project hero, the industry-side problem stated in
[[sysmod-neg-human-dimension]].

The closing line of the source's case-study discussion is the shortest
statement of the whole procedure. If you cannot make the right thing the
easiest thing to notice and do, your process will drift.

## See also

- [[phas-eai-overview]] for the regime and practice constructs and the four
  mechanisms.
- [[phas-eai-active-inference-model]] for precision, salience, and affordance
  in formal terms.
- [[phas-eai-levers-and-evidence]] for H9 and its cross-case support.
- [[phas-eai-de-requirements]] for R4 and the plugin mapping.
