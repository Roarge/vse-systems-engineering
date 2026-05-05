// Stakeholder roles for the Smart Sensor project.
//
// Per methodology §1.3 and §1.4.1, each role is its own `part def`.
// No abstract `Stakeholder` parent. The same part def is reused as
// the actor type in the System Context (§3.3.2) where the role
// interacts with the system.

package SmartSensor_Stakeholders {

    // Customer-facing user who reads dashboard data and acknowledges
    // alerts. Interacting stakeholder, appears as actor in §3.
    part def Operator;

    // Field technician who installs the device, calibrates it, and
    // services it. Interacting stakeholder, appears as actor in §3.
    part def MaintenanceTechnician;

    // External authority. Non-interacting stakeholder, holds
    // concerns about data retention and equipment certification.
    // Does not appear as actor in §3.
    part def Regulator;
}
