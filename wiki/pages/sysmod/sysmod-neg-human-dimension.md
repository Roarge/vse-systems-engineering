---
title: "The human dimension: craftsmanship, New Work, and the gap of slackness"
slug: sysmod-neg-human-dimension
type: concept
layer: sysmod
summary: Craftsmanship over Taylorism, New Work values, the gap of slackness, and the project-hero burnout warning
tags: [neg, craftsmanship, taylorism, new-work, gap-of-slackness, project-heroes, burnout, attention]
sources:
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.6 (The Resurrection of Craftsmanship)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.7 (New Work)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.8 (Gap of Slackness)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §3.9 (Project Heroes and Burnout)"
    raw: new-engineering-game.pdf
  - citation: "Weilkiens, T. (2018). The New Engineering Game: Strategies for Smart Product Engineering. MBSE4U. §2.2 (The Second Industrial Revolution)"
    raw: new-engineering-game.pdf
related:
  - phas-eai-overview
  - phas-eai-de-requirements
  - phas-eai-levers-and-evidence
  - phas-eai-designing-attention-regimes
  - phas-eai-llm-peer-review
  - sysmod-neg-complexity-and-dynamics
confidence: medium
created: 2026-08-13
updated: 2026-08-13
referenced_by: [attention-regime]
---

# The human dimension: craftsmanship, New Work, and the gap of slackness

## Contents

- Taylorism in two sentences
- The Taylor tube
- Why indirection blocks the feedback loop
- New Work
- The Gap of Slackness
- The early-warning signals
- Project heroes and burnout
- Where this meets the plugin's design rationale
- A tension worth stating
- See also

Confidence note: this page is `medium` rather than `high` for two
reasons. The Taylor tube and the Gap of Slackness are informal models.
Both are drawn as curves in the source, neither curve carries units or
a measurement procedure, and their value is as vocabulary for a
conversation rather than as anything a project could calibrate. The
New Work material is a set of social observations made in 2018 about a
movement that was then in progress, so its claims about what a
workforce wants are dated by construction. The burnout and
communication-load material rests on cited research and is firmer than
the rest.

## Taylorism in two sentences

Scientific management, associated with Frederick Winslow Taylor,
transferred control from the workers to the management. Managers plan
the work and specify how it is to be performed, and the workers execute
the tasks.

The source adds one observation that the rest of this page depends on.
The separation of control and work has lasted until today, and it has
started to turn back, so that control and work are merging again.

## The Taylor tube

Gerhard Wohland's name for the pattern of organisational complexity
plotted along a timeline is the Taylor tube, and the source reproduces
it.

The curve falls through the era of mass production. Machines performed
more and more production steps, production followed predefined fixed
steps, and the complexity of the processes decreased accordingly. The
curve then rises again, and the source attributes the rise to the
tightness of the markets. Markets now demand customised products, and
delivering customised products at production volume requires complex
automation and engineering craftsmanship, which is the same turning
point [[sysmod-neg-complexity-and-dynamics]] records from the
technology side.

The source's conclusion is a comparative rather than an absolute one.
To remain successful, the focus must move from processes back to
craftsmanship. Processes have value without doubt, and the value of
craftsmanship is higher.

## Why indirection blocks the feedback loop

Individual customer requirements need the customer in close contact
with the producer. Agile methods do exactly this, integrating customers
into the development process to create a tight loop between
requirements and product feedback.

Taylorism prevents that integration. Creation of the product is
decoupled from control and management, and the controlling side
typically also owns communication with the customer. Two costs follow.
Without contact with the markets and the users, the right feeling for
the right products cannot emerge in the engineering departments. The
indirection itself also costs time and quality, and the source's
position is that neither can be afforded by an organisation that
intends to succeed.

## New Work

New Work is described as a movement changing the working world, mainly
for knowledge workers, driven by two things.

The first is a shift in what the younger working generation values. As
industrial societies become knowledge societies, money, career, and
status symbols stop being the most important drivers, and work-life
balance, meaning, and meaningful work take their place. The second is
the internet, which makes collaboration independent of location and
therefore makes several long-standing arrangements look arbitrary. The
source lists the questions the movement asks, and they are worth
reading as written, because each one is a challenge to a specific
management practice.

- Why should someone else, called a boss, decide what I do, if I can
  decide it better and more effectively?
- If I can work at any time and anywhere, why must I be in the office
  from nine to five?
- Why must I record my working times, when the outcome matters rather
  than the effort?
- If what I know matters more than what I can do, what does my leaving
  mean for the company?

The values the source names for the new work culture are independence,
freedom, and co-design of one's own work environment. Its argument for
why an engineering organisation must take them seriously is
instrumental rather than moral: dynamic and complex markets demand
flexibility, creativity, and craftsmanship, and those capabilities are
closely related to employees being content. The working culture left
behind by the earlier industrial revolutions produced the opposite,
namely strong dependencies and constraints with little scope to
influence one's own working environment. Scrum is named as a visible
instance of the shift, promoting self-organised teams and moving
control from project and team leaders back to the engineers.

## The Gap of Slackness

The source plots two curves against time on the same axis of vendor
challenges, which it lists as more complexity, less time to market,
less cost, and perfect quality.

- The **product curve** always rises, reflecting steadily increasing
  demand for improvement. Globalisation and the dynamics that come with
  it change its slope from linear to exponential.
- The **methods and tools curve** sits a little below the product
  curve, because the methods and tools used to build the products must
  improve as well.

The distance between the two curves has two names, and the difference
between them is the point of the model. The ordinary distance is called
the Gap of the Project Heroes, and it is bridged by people who do
outstanding work, save deadlines, and have the right ideas at the right
time. When the product curve turns exponential, the distance grows into
the Gap of Slackness, which heroes cannot bridge. The source's
diagnosis of the cause is uncomfortable and simple: the organisation
does not spend time on sharpening its engineering tools, because it is
too busy developing products with blunt tools.

Closing the gap is not a technical task alone. New products and
features can imply disruptive changes to existing product
architectures, and by Conway's Law that can force organisational
change.

## The early-warning signals

The source lists what an organisation sees when the gap has opened, and
it notices the social signals before the engineering ones.

- On the social level: people become frantic, the atmosphere becomes
  unpleasant, and the sickness absence rate rises.
- On the engineering level: quality falls and deadlines are missed.

The timing instruction that follows is the practical value of the whole
model. Recognising the gap when it appears is already too late, because
adopting new engineering methods and tools takes time before it becomes
effective, and the change costs time and money first. Those are
precisely the two things an organisation does not have once the
situation has become critical, so the gap has to be forecast rather
than observed.

## Project heroes and burnout

Project heroes make the impossible possible, and their power is not
boundless. The source treats a hero in trouble as an indicator that the
organisation is in trouble.

The rule it derives is narrow and firm. Project heroes can help out
with short-term challenges and must not be part of an organisational
strategy. An organisation that does not fill the gaps its heroes
bridged is implicitly and continuously requesting a high-speed working
style.

Stress and overload can produce burnout, which is hard to detect before
it is too late, since often the only visible sign from a project hero
is a sick note. The source records that burnout is an old phenomenon
that used to affect executives and now reaches non-executives as well,
in particular where a new-work environment distributes managerial
functions and responsibilities beyond the executive layer.

Two further points close the section.

- **Always-on communication is a workload, not a free extra.**
  Information and communication technologies make employees reachable
  around the clock, and research from Connected Commons found that most
  managers spend more than 85 percent of their time in meetings,
  email, and other communication channels. Communication and networks
  are valuable assets and have to be managed, which the source names as
  an organisational task rather than an individual one. The article
  "Collaboration without Burnout" by Rob Cross and colleagues is cited
  for self-management practices covering beliefs, role, schedule,
  network, and behaviour.
- **Check what commitment rests on.** The source's two questions for a
  team member's commitment are whether it is based on enthusiasm or on
  closing a deficit, and whether it is temporary or permanent.

## Where this meets the plugin's design rationale

This page is routed to the attention-regime skill because the source
arrives, from an entirely different direction, at the problem the
plugin's design rationale was built to address.

- **The methods and tools curve is designed cognitive reserve.** What
  the source draws as a curve that must be raised before the gap opens
  is what PHAS-EAI formalises as `h`, the fraction of cognitive
  headroom guaranteed by design rather than by individual skill. See
  [[phas-eai-overview]]. The floor property formalises the
  skill-independence half of the argument: raising `h` is what stops
  performance depending on whether the right person is available on the
  right day. The timing instruction, forecast the gap rather than wait
  to observe it, stands beside that as the source's own contribution.
  [[phas-eai-llm-peer-review]] records one concrete way of raising the
  curve without a hero, by giving a small team review competence it
  could not otherwise afford.
- **The hero warning converges with hypothesis H7.** The source says
  heroes may bridge short-term trouble and must not be an
  organisational strategy. H7 predicts that increasing designed reserve
  yields larger resilience gains than equivalent investment in raising
  individual skill, with cross-case support recorded in
  [[phas-eai-levers-and-evidence]]. The two statements are the same
  claim in different registers, one from practice and one from the
  case evidence.
- **The structures that close the gap are Regimes of Attention.** The
  source asks for sustained investment in methods and tools that
  survives schedule pressure, and never names a mechanism for making
  that investment survive. R4 is that mechanism, and
  [[phas-eai-de-requirements]] states it: environmental structures such
  as hooks, gates, and dashboards keep dependability salient when
  competing priorities would otherwise displace it.
  [[phas-eai-designing-attention-regimes]] is the published worked
  example of that mechanism, applied by a company of comparable size to
  a concern the source would recognise.

## A tension worth stating

The two sources do not agree on where to intervene, and the
disagreement is more useful stated than smoothed over.

Weilkiens quotes Wohland to the effect that the first question when a
surprise occurs is who should handle it rather than how it should be
handled, and that the task is to find the right person instead of the
right process. That is a person-first prescription. PHAS-EAI argues the
opposite emphasis, that designed environmental reserve outperforms
investment in individual skill, which is an environment-first
prescription.

Read together with the source's own later sections, the two converge.
The book itself says that heroes have limits, that an organisation must
not rely on them, and that the organisation has to raise the methods
and tools curve before the gap opens. Raising that curve is precisely
what PHAS-EAI formalises as raising `h`. The person-first line applies
to the moment a surprise arrives, when no process exists yet and
somebody has to act. The environment-first argument applies to what the
organisation does between surprises so that fewer of them require a
hero. The reconciliation is a division of scope, not a compromise:
find the right person for the surprise in front of you, and build the
reserve that reduces how often the surprise needs one.

## See also

- [[sysmod-neg-complexity-and-dynamics]] for the market and complexity
  pressures behind the Taylor tube and the Gap of Slackness.
- [[phas-eai-overview]] for designed cognitive reserve and Regimes of
  Attention.
- [[phas-eai-de-requirements]] for R1 to R4 and their plugin mappings.
- [[phas-eai-levers-and-evidence]] for H7 and the cross-case evidence
  behind it.
