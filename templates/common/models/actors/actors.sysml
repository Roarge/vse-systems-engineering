// {{PROJECT_NAME}} — Actors
//
// Actor part defs, external systems, and operators that interact with
// the system of interest. Imported by {{PROJECT_SHORT_CODE}}_UseCases
// and {{PROJECT_SHORT_CODE}}_StakeholderNeeds.
//
// Source: Douglass 2021 Agile MBSE Cookbook, Fig 1.35 Actor Package.
// Authoring help: @sysml2-model-structure, @sysml2-cases

package {{PROJECT_SHORT_CODE}}_Actors {
    doc /* External actors and systems.
           Replace the example actor below with real actors as they are
           identified during stakeholder analysis. Each actor should have
           a short doc comment naming its role and responsibilities.
         */

    part def Operator {
        doc /* Primary human operator of {{PROJECT_NAME}}.
               Responsibilities: (to be filled in).

               Once interfaces are introduced in
               {{PROJECT_SHORT_CODE}}_Interfaces, add port
               declarations here for the interfaces this actor
               participates in. For example:
                   port configOut : ConfigPort;
               This allows the actor to appear in connect
               statements inside SystemOfInterest or SystemContext
               in {{PROJECT_SHORT_CODE}}_ArchDesign.
             */
    }

    // Add further actors here, one part def per actor.
    // part def MaintenanceTechnician { ... }
    // part def ExternalMonitoringSystem { ... }
}
