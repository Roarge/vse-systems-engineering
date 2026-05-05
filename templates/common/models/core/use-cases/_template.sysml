// Use cases as story elaborations (§1.4.5).
//
// A use case declares the user story as its `objective` per spec
// §7.21.2. The use case's `subject` shall conform to the story's
// `subject`. The use case's `actor` representing the story's role
// shall be typed by the same part def as the story's role (§1.9
// rule 5). Use cases are optional. Many stories never warrant one.

package {{PROJECT_NAME}}_UseCases {

    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_StakeholderStories::*;

    use case def AcknowledgeAlarms {
        subject sys : {{PROJECT_NAME}}_System;
        actor performer : Operator;

        // The story this use case elaborates.
        objective realisesUS001 : US_001_Example;

        // Action body. Use one of three §5.4.3 approaches:
        // flow-based (action def with item flows), scenario-based
        // (sequence-style actions), or state-based (state def).
        action mainFlow {
            doc /* Operator opens dashboard. System lists unack alarms.
                   Operator selects "Ack all". System transitions all
                   alarms to acknowledged within the SLA. */
        }
    }
}
