// {{PROJECT_NAME}} — Model Overview
//
// Root overview file for the SE model. Holds no engineering content.
// Cross-links each top-level package and points at the model overview
// diagram referenced in the SEMP.
//
// Each top-level package lives in its own directory, containing the
// package definition file and a co-located view file that exposes
// the package contents through an appropriate SysML 2.0 standard view.
// Cross-cutting views that span multiple packages live at this root
// level alongside this overview file.
//
// Canonical layout source: Douglass B P (2016) Agile Systems Engineering,
// Ch 3.2.5 Fig 3.13, and Douglass B P (2021) Agile MBSE Cookbook, Ch 1
// Fig 1.35-1.36.
// Authoring help: @sysml2-model-structure

package {{PROJECT_SHORT_CODE}}_Model {
    doc /* {{PROJECT_NAME}} systems engineering model.
           This package is a root overview only. The engineering content
           lives in the peer top-level packages, each in its own
           directory with a co-located package view.

           Always present (Minimal and Canonical tiers):
             Directory                  Package                          View Type
             actors/                    {{PROJECT_SHORT_CODE}}_Actors                General View
             stakeholder-needs/         {{PROJECT_SHORT_CODE}}_StakeholderNeeds      Grid View
             use-cases/                 {{PROJECT_SHORT_CODE}}_UseCases              General View
             requirements/              {{PROJECT_SHORT_CODE}}_Requirements          Grid View
             arch-design/               {{PROJECT_SHORT_CODE}}_ArchDesign            Interconnection View
             interfaces/                {{PROJECT_SHORT_CODE}}_Interfaces            Interconnection View
             verification/              {{PROJECT_SHORT_CODE}}_Verification          Grid View
             risks/                     {{PROJECT_SHORT_CODE}}_Risks                 Grid View
             library/                   VSE_Library                      (metadata, no view)

           Added by the Canonical AMBSE tier (default):
             functional-analysis/       {{PROJECT_SHORT_CODE}}_FunctionalAnalysis    Action Flow View
             arch-analysis/             {{PROJECT_SHORT_CODE}}_ArchAnalysis          Grid View
             configurations/            {{PROJECT_SHORT_CODE}}_Configurations        Grid View

           Optional peers (independent opt-ins):
             base-architecture/         {{PROJECT_SHORT_CODE}}_BaseArchitecture      Interconnection View
             cm/                        {{PROJECT_SHORT_CODE}}_CM                    Grid View

           Cross-cutting views (at this root level):
             traceability-view.sysml    {{PROJECT_SHORT_CODE}}_TraceabilityView      Grid View
         */
}
