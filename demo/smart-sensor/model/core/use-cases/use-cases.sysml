// Smart Sensor use cases (§1.4.5).
//
// Per methodology §1.4.5, a use case is an *elaboration* of one or
// more user stories, not a parallel artefact. It expresses a longer
// scenario whose narrative is awkward to compress into a single
// `acceptance` body. The use case lives at the same level as the
// story it elaborates and points back to it via `derive`.
//
// Smart Sensor uses one elaboration: the alert-acknowledgement
// scenario for US_002 / SYS_002, which has multiple steps and a
// timing constraint that benefits from a step-by-step narrative.

package SmartSensor_UseCases {

    private import SmartSensor_Stakeholders::*;
    private import SmartSensor_Context::*;
    private import SmartSensor_Domain::*;
    private import SmartSensor_StakeholderStories::*;
    private import VSE_Library::*;

    // Use case for the batch alert acknowledgement story. Elaborates
    // US_002_AcknowledgeAlertsBatched. The flow shows the operator,
    // the dashboard, the cloud broker, and the device co-operating to
    // clear an alert batch within the SLA.
    use case def AcknowledgeAlertBatch {
        doc /* #derive from US_002_AcknowledgeAlertsBatched.

               Primary actor: Operator.
               Secondary actor: CloudDashboard (the device holding
               the alerts is the system itself, declared as
               `subject`; the cloud-side MQTT broker is a Base
               Architecture element and is not declared as a
               separate use-case actor).

               Trigger: the alert queue contains N unacknowledged
               alerts (N up to maxBatchSize).

               Main success scenario:
                 1. The operator opens the dashboard alerts view.
                 2. The dashboard displays unacknowledged alerts.
                 3. The operator selects "Acknowledge all".
                 4. The dashboard composes one acknowledgement
                    command per alert and dispatches them via the
                    cloud broker.
                 5. The system transitions all selected alerts to
                    acknowledged within maxBatchAckLatency.
                 6. The dashboard renders the cleared queue.

               Postconditions: all selected alerts are in the
               acknowledged state both in the cloud store and on the
               device. */

        subject system     : SmartSensor_System;
        actor operator     : Operator;
        actor dashboard    : CloudDashboard;

        // Per methodology §1.4.5, the use case declares the story it
        // elaborates as its `objective`. This couples the actor to
        // the stakeholder by shared typing of `Operator`.
        objective realisesUS002 : US_002_AcknowledgeAlertsBatched;
    }
}
