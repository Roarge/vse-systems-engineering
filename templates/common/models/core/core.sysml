// Core package for {{PROJECT_NAME}}.
//
// Top-level package per methodology §8.3.1. Imports the sub-packages
// listed below. Add or remove imports as the project model grows.
//
// The angle-bracket form is the project's 3-5 letter short code per
// §8.3.4 of the methodology spec, for example <Aiwell> or <FFDS>.
// Replace {{PROJECT_SHORT_CODE}} with the project's short code at
// /vse-setup time.

package <{{PROJECT_SHORT_CODE}}> {{PROJECT_NAME}}_Core {

    // Foundational artefacts (§1, §2, §3)
    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Concerns::*;
    private import {{PROJECT_NAME}}_BaseArchitecture::*;
    private import {{PROJECT_NAME}}_Context::*;
    private import {{PROJECT_NAME}}_Domain::*;

    // Story register (§4 stakeholder, §5 system)
    private import {{PROJECT_NAME}}_StakeholderStories::*;
    private import {{PROJECT_NAME}}_SystemStories::*;

    // Behavioural elaborations (§1.4.5 use cases, §5.4.3 actions/states)
    private import {{PROJECT_NAME}}_UseCases::*;
    private import {{PROJECT_NAME}}_FunctionalArchitecture::*;

    // Architecture (§7 logical, §7 product)
    private import {{PROJECT_NAME}}_LogicalArchitecture::*;
    private import {{PROJECT_NAME}}_ProductArchitecture::*;

    // Cross-cutting (§7.3.6 control laws, system-level processes)
    private import {{PROJECT_NAME}}_Parametrics::*;
    private import {{PROJECT_NAME}}_Processes::*;

    // Verification and validation (§4.3.6, §5.4.6)
    private import {{PROJECT_NAME}}_VerificationCases::*;
    private import {{PROJECT_NAME}}_ValidationCases::*;
}
