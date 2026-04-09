// {{PROJECT_NAME}} — Base Architecture (OPTIONAL)
//
// Optional top-level package holding an inherited base architecture.
// Scaffolded only when project-setup is run with the base-architecture
// opt-in, or in brownfield mode against an existing SysML tree.
//
// {{PROJECT_SHORT_CODE}}_ArchDesign imports and specialises the part
// defs declared here via the Ch 14 operators :> (definition
// specialisation) and :>> (usage redefinition).
//
// Source: *The SysML v2 Book* Ch 14.1-14.2 specialisation syntax;
// Douglass 2016 Agile Systems Engineering Ch 8 shared-repository
// pattern. When the base is shared across multiple programmes, migrate
// it out of this SE model and into a dedicated shared model.
// Authoring help: @sysml2-model-structure Section 3

package {{PROJECT_SHORT_CODE}}_BaseArchitecture {
    doc /* Inherited base architecture for {{PROJECT_NAME}}.
           Holds stable part defs that the project reuses from a prior
           programme. Volatile content stays in
           {{PROJECT_SHORT_CODE}}_ArchDesign.
           When the base matures and is shared across programmes,
           migrate it into a peer shared model.
         */

    part def BaseSystem {
        doc /* Base system definition from the prior programme.
               {{PROJECT_SHORT_CODE}}_ArchDesign::SystemOfInterest uses
               :> BaseSystem to specialise it.
             */
    }

    part def BaseOperator {
        doc /* Base operator role inherited from the prior programme. */
    }

    part def BaseEnvironment {
        doc /* Base environment definition inherited from the prior
               programme. Redefine environmental parameters in
               {{PROJECT_SHORT_CODE}}_ArchDesign via :>>.
             */
    }
}
