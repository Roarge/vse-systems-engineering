// Concern register.
//
// Per methodology §1.4.6 (frame concern) and §4.3.2, each stakeholder
// concern is declared as a `concern def`. Concerns persist across
// iterations and are framed by stories that address them.
//
// A concern carries:
//   - subject (the system or subsystem the concern bears on)
//   - stakeholder (the part def from core/stakeholders/)
//   - require constraint (the underlying need)

package {{PROJECT_NAME}}_Concerns {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Context::*;

    // Example concern: operations team's worry about incident response time.
    concern def FastIncidentResponse {
        subject system : {{PROJECT_NAME}}_System;
        stakeholder ops : Operator;

        require constraint {
            doc /* Operations need short time-to-acknowledge to meet
                   SLA targets for incident response. */
        }
    }

    // Add project-specific concerns here. Each concern is the
    // persistent, n:m anchor that one or more stories will frame.
}
