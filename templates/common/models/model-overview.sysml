// {{PROJECT_NAME}} — Model Overview
//
// Root overview file for the SE model. Holds no engineering content.
// Cross-links each top-level package and points at the model overview
// diagram referenced in the SEMP.
//
// Canonical layout source: Douglass B P (2016) Agile Systems Engineering,
// Ch 3.2.5 Fig 3.13, and Douglass B P (2021) Agile MBSE Cookbook, Ch 1
// Fig 1.35-1.36.
// Authoring help: @sysml2-model-structure

package {{PROJECT_SHORT_CODE}}_Model {
    doc /* {{PROJECT_NAME}} systems engineering model.
           This package is a root overview only. The engineering content
           lives in the peer top-level packages:
             - {{PROJECT_SHORT_CODE}}_Actors           (external actors)
             - {{PROJECT_SHORT_CODE}}_StakeholderNeeds (needs and subject)
             - {{PROJECT_SHORT_CODE}}_UseCases         (use cases)
             - {{PROJECT_SHORT_CODE}}_Requirements     (system requirements)
             - {{PROJECT_SHORT_CODE}}_FunctionalAnalysis (one nested package per use case)
             - {{PROJECT_SHORT_CODE}}_ArchAnalysis     (one nested package per trade study)
             - {{PROJECT_SHORT_CODE}}_ArchDesign       (selected architecture, one nested package per subsystem)
             - {{PROJECT_SHORT_CODE}}_Interfaces       (logical interfaces and data schema)
             - {{PROJECT_SHORT_CODE}}_Verification     (verification cases)
             - {{PROJECT_SHORT_CODE}}_Risks            (risk register)
           Optional peers when activated by project-setup:
             - {{PROJECT_SHORT_CODE}}_BaseArchitecture (inherited base)
             - {{PROJECT_SHORT_CODE}}_Configurations   (concrete variant configurations)
             - {{PROJECT_SHORT_CODE}}_CM               (model-level baselines and CIs)
         */
}
