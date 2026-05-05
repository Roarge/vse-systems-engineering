// Stakeholder role part defs.
//
// Per methodology §1.3 and §1.4.1, each stakeholder role is declared
// as its own `part def`. There is no abstract `Stakeholder` parent.
// The same `part def` is reused wherever the stakeholder appears as
// an `actor` in the System Context (§3.3.2) or in a use case bound
// to a story via `objective` (§1.4.5).

package {{PROJECT_NAME}}_Stakeholders {

    // Example: a human operator who interacts with the system.
    part def Operator;

    // Example: a maintainer who services the system in the field.
    part def Maintainer;

    // Example: a regulator who imposes compliance requirements.
    // Regulators do not interact with the system, but they hold
    // concerns that frame stories. Per methodology, regulators are
    // valid stakeholders that need not appear in the System Context.
    part def Regulator;

    // Add project-specific stakeholders here. One part def per role.
    // Reuse the same part def in core/context/ for the actor typing.
}
