# PHAS-EAI Framework Reference

> Source: Georgsen, R. E. (2026). _Resilient Smart City Design_ (Doctoral thesis).
> Sections 4.2.2-4.2.5, 5.5, 6.5, 7.4-7.5.
> Purpose: Concise reference for the VSE Systems Engineering plugin.

---

## 1. Core Constructs

### 1.1 Configuration Space

The system state is modelled as a product of seven configuration dimensions:

    X = X_tech * X_org * X_policy * X_practice * X_language * X_worldview * X_boundary

Each dimension contains a finite set of possible settings. Table 12 in the thesis
maps each dimension to observable indicators (for example, X_tech includes hardware
platforms, software stacks, and interface standards).

Hard constraints K remove infeasible combinations, yielding the feasible set
O^Delta. A binning map phi groups similar configurations to produce distinct
options. Complexity is then:

    C = |O^Delta|       (count of feasible distinct options)

Complexity potential for a single dimension i:

    CP_i = |X_i| / |X_i^min|

Higher CP_i means the dimension contributes more to total optionality.

### 1.2 Designed Cognitive Reserve

Designed cognitive reserve (h) is the fraction of cognitive headroom guaranteed by
design, independent of individual skill. It is achieved through automation,
checklists, pre-authorised actions, and scaffolded workflows.

Cognitive headroom:

    H_cog = h + (1 - h) * u(E, MF) * q(IT)

where u(E, MF) is a skill factor (experience E, mental fitness MF, both in [0,1])
and q(IT) is the inference-tool quality factor.

**Floor property:** H_cog >= h regardless of skill. When u = 0 (novice, fatigued),
headroom equals h. This is what makes reserve "designed" rather than accidental.

Plugin implication (R2): LLM-assisted workflows raise h by embedding SE competence
in the toolchain, so that even inexperienced VSE staff maintain a minimum
performance floor.

### 1.3 Regimes of Attention

An institutional arrangement that increases the precision of dependability signals
and the affordance of dependability actions. Four formal mechanisms:

1. **Noise reduction.** Filters irrelevant signals so that dependability-relevant
   information stands out.
2. **Observation mapping.** Improves the mapping from hidden system states to
   observable indicators (increases omega precision).
3. **Affordance increase.** Raises the perceived and actual feasibility of
   dependability actions, lowering the activation threshold.
4. **Expectation stabilisation.** Creates shared priors across team members,
   reducing coordination cost.

Regimes of Attention are not one-off interventions. They are sustained
environmental structures (review gates, dashboards, automated checks) that keep
dependability visible under workload pressure.

Plugin implication (R4): Hooks and guards in the plugin sustain attention by
triggering at lifecycle boundaries, preventing silent drift away from process
compliance.

### 1.4 Patterned Practices

Regular, ritualised interactions through which agents engage with Regimes of
Attention and internalise knowledge. Examples from the case studies:

- End-of-Phase (EoP) game sessions (Case B)
- LLM-assisted review pipelines (Case D)
- Patch-triage huddles (Case C)
- Structured lessons-learned workshops (Case A)

Patterned Practices reduce functional information by narrowing the success set to
well-understood routines. They function as implementation guides that translate
abstract process requirements into operational habits.

Plugin implication (R1): Skills in the plugin encode Patterned Practices as
reusable, phase-specific workflows.

### 1.5 Niche Construction

Teams actively reshape their environment to support their own inference. This
creates feedback loops where the modified environment reinforces desired behaviour,
which in turn motivates further environmental modification.

In the PHAS-EAI model, niche construction explains why some teams sustain good
practices while others drift: the environment either reinforces or undermines the
inference system that drives behaviour.

---

## 2. Key Equations

### 2.1 Response Time

    tau = tau_detect + tau_decide + tau_execute

Each stage is scaled by structural drag from complexity potential:

    tau_detect = tau_detect^base * product(CP_i^alpha_i)
    tau_decide = tau_decide^base * product(CP_i^beta_i)
    tau_execute = tau_execute^base * product(CP_i^gamma_i)

Skill reduces response time via the time multiplier:

    sigma_tau = 1 - lambda_tau * u(E, MF)

where lambda_tau in [0,1] is the maximum fractional reduction achievable through
skill.

### 2.2 Resilience Score

    R(M, tau_d) is a piecewise function on [0, 1]:
    - R = 1   if system absorbs disturbance within tau_d (deadline)
    - R = f_A  partial absorption (graceful degradation)
    - R = f_B  adaptive response (reconfiguration)
    - R = f_C  transformative response (fundamental change)
    - R = 0   if system fails to respond

Response functions f_A, f_B, f_C are ordered: f_A > f_B > f_C, reflecting
decreasing desirability of deeper adaptation.

### 2.3 Functional Information

    I*_g(rho) = -log2 p_g(rho)

where p_g(rho) is the probability that a randomly chosen configuration achieves
goal g at performance threshold rho. Higher functional information means fewer
configurations succeed, so choice is costlier.

Operational functional information adds time pressure:

    I^op_g = I*_g - log2 f_A

where f_A captures the fraction of the success set accessible under time and
resource constraints.

---

## 3. DE Integration Requirements (Table 24)

These four requirements link the formal model to digital engineering tool design.

### R1: Reduce Functional Information Burden

| Aspect       | Detail                                                      |
|-------------|-------------------------------------------------------------|
| Model link  | C (complexity), \|A_g,rho\|/C (success set ratio), I*_g     |
| Metrics     | Option count proxies, success set estimates, quality scores |
| Case support| A, B, C, D                                                  |
| Mechanism   | Tools narrow the configuration space before the human       |
|             | decides, reducing I*_g without removing valid options.      |

Plugin mapping: Skills pre-filter lifecycle activities by phase and context,
presenting only relevant options to the user.

### R2: Build Designed Cognitive Reserve

| Aspect       | Detail                                                      |
|-------------|-------------------------------------------------------------|
| Model link  | h (reserve floor), lambda_tau (skill multiplier)            |
| Metrics     | Personnel-change robustness, tool-dependency ratios,        |
|             | internalisation indicators                                  |
| Case support| A, B, C, D                                                  |
| Mechanism   | Embed SE competence in the toolchain so that performance    |
|             | floor h is maintained even with staff turnover.             |

Plugin mapping: The LLM acts as embedded SE competence, providing guidance that
does not depend on the individual user having deep SE experience.

### R3: Provide Machine-Readable Traceability

| Aspect       | Detail                                                      |
|-------------|-------------------------------------------------------------|
| Model link  | omega (observation precision), g(.) (generative model),     |
|             | Phi (inference mapping)                                     |
| Metrics     | Detection-to-decision time, integration surprise rate,      |
|             | decision rework rate                                        |
| Case support| A, B, C, D                                                  |
| Mechanism   | Machine-readable models increase omega, making hidden       |
|             | states observable and reducing detection lag.               |

Plugin mapping: SysML 2.0 textual models provide traceability that both humans and
tools can parse, reducing tau_detect.

### R4: Sustain Attention Through Environmental Design

| Aspect       | Detail                                                      |
|-------------|-------------------------------------------------------------|
| Model link  | Regime of Attention, precision weighting                    |
| Metrics     | Drift indicators, engagement persistence, remediation rate  |
| Case support| B, C, D                                                     |
| Mechanism   | Environmental structures (hooks, gates, dashboards)         |
|             | maintain dependability salience under workload pressure.    |

Plugin mapping: Hooks fire at lifecycle transitions, guards check model
consistency, preventing silent process drift.

---

## 4. Lever Tables (Tables 17-20)

### Table 17: Configuration-Space Levers

| Lever                  | If moved up                        | If moved down                    |
|-----------------------|-------------------------------------|----------------------------------|
| Hard constraints K    | Fewer feasible options, lower C     | More options, higher C           |
| Dimension count       | Larger space, harder to search      | Smaller space, easier to manage  |
| Binning granularity   | Coarser bins, fewer distinct options| Finer bins, more distinct options|
| Coupling between dims | More constraints propagate          | Dimensions more independent      |

### Table 18: Mobilisation-Time Levers

| Lever                  | If moved up                        | If moved down                    |
|-----------------------|-------------------------------------|----------------------------------|
| Designed reserve h    | Higher floor on headroom            | Floor drops, skill-dependent     |
| Skill factor u        | Faster response, lower sigma_tau    | Slower response                  |
| Tool quality q(IT)    | Better headroom utilisation         | Tools become bottleneck          |
| Structural drag (CP)  | Longer stage times                  | Shorter stage times              |

### Table 19: Information and Inference Levers

| Lever                  | If moved up                        | If moved down                    |
|-----------------------|-------------------------------------|----------------------------------|
| Observation precision | More accurate state estimates       | Noisier signals, worse decisions |
| Generative model fit  | Better predictions, less surprise   | More prediction errors           |
| Functional info I*    | Costlier choices, more expertise    | Easier choices, lower barrier    |
| Success set ratio     | More paths to goal, more forgiving  | Fewer paths, less margin         |

### Table 20: Coordination and Governance Levers

| Lever                  | If moved up                        | If moved down                    |
|-----------------------|-------------------------------------|----------------------------------|
| Shared priors         | Lower coordination cost             | More misalignment, rework        |
| Regime of Attention   | Sustained dependability focus       | Attention drifts to urgent tasks |
| Practice ritualisation| Stronger habits, less cognitive load | Ad hoc behaviour, inconsistency  |
| Niche construction    | Environment reinforces good practice| Environment undermines practice  |

---

## 5. Complementarity with ISO 29110

ISO/IEC 29110 specifies WHAT activities to perform. PHAS-EAI explains WHY those
activities work and what sustains them. The relationship is complementary:

1. **Process mandates are necessary but insufficient.** In resource-constrained
   settings, inference systems deprioritise low-affordance activities under
   workload pressure. Without Regimes of Attention, process mandates decay.

2. **Regimes of Attention provide the missing mechanism.** They make process
   compliance visible and actionable, bridging the gap between what the standard
   requires and what teams actually do.

3. **Machine-readable traceability (H14) supports quality evidence.** ISO 29110
   certification requires documented evidence of process execution. SysML 2.0
   models and automated checks generate this evidence as a by-product of normal
   work, rather than as separate documentation effort.

4. **Designed cognitive reserve (H7) addresses the staffing constraint.** Laporte
   identified limited SE expertise as the central barrier for VSEs. By embedding
   competence in the toolchain, designed reserve compensates for the expertise
   gap without requiring additional hires.

5. **Patterned Practices translate process into action.** They function as
   implementation guides that convert ISO 29110 activity descriptions into
   operational routines suited to the team context.

---

## 6. Hypotheses with Strongest Cross-Case Support

The thesis tests 14 hypotheses (H1-H14) across four cases (A-D). Four hypotheses
achieved convergent support across three or more cases:

### H7: Designed Reserve Outperforms Experience Investment

Prediction: Increasing designed reserve h yields larger resilience gains than
equivalent investment in raising individual skill u(E, MF).

Evidence: Direct support from Cases A (episode A1), B (B1), C (C1), D (D4).
Teams with higher h sustained performance through personnel changes, while
teams relying on individual expertise suffered when key staff departed.

### H9: Regimes of Attention Reduce Drift

Prediction: Teams operating within a Regime of Attention show lower rates of
process drift than those without.

Evidence: Direct support from Cases B (B1), C (C2), D (D2). The mechanism
operates through precision weighting: the regime keeps dependability signals
salient even when competing priorities demand attention.

### H13: Patterned Practices Reduce Functional Information

Prediction: Established Patterned Practices reduce I*_g by narrowing the
configuration space to proven routines, lowering the cognitive cost of choosing
correctly.

Evidence: Direct support from Cases A (A1), B (B3), C (C4), D (D3). Teams
with ritualised practices made faster, more consistent decisions. New team
members reached baseline competence sooner when practices were explicit.

### H14: Machine-Readable Traceability Reduces Noise

Prediction: Machine-readable models improve observation precision omega,
reducing detection time and decision rework.

Evidence: Direct support from Cases A (A3, A4), B (B2), C (C3), D (D4).
The effect was strongest when traceability was integrated into daily tools
rather than maintained as a separate artefact.

---

## 7. Quick-Reference Summary

| Construct               | Model symbol    | Plugin lever         | DE Req |
|--------------------------|----------------|----------------------|--------|
| Configuration space      | X, C, CP_i     | Context filtering    | R1     |
| Designed cognitive reserve| h, H_cog      | LLM as embedded SE   | R2     |
| Observation precision    | omega          | SysML 2.0 models     | R3     |
| Regime of Attention      | precision wt.  | Hooks and guards     | R4     |
| Patterned Practices      | I*_g reduction | Phase-specific skills| R1     |
| Niche Construction       | feedback loops | Workspace conventions| R4     |
| Response time            | tau, sigma_tau | Automation, templates| R2     |
| Functional information   | I*_g, I^op_g  | Option pre-filtering | R1     |
