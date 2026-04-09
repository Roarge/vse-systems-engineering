// {{PROJECT_NAME}} — Functional Analysis
//
// Functional decomposition of the system, with one nested sub-package
// per analysed use case. Each sub-package holds the actions, flows, and
// state bodies that realise the use case.
//
// Source: Douglass 2016 Agile Systems Engineering, Fig 3.13
// FunctionalAnalysisPkg; Douglass 2021 Agile MBSE Cookbook, Fig 1.35
// Functional Analysis Package.
// Authoring help: @sysml2-behaviour, @architecture-design

package {{PROJECT_SHORT_CODE}}_FunctionalAnalysis {
    doc /* Functional analysis for {{PROJECT_NAME}}.
           AMBSE convention: one nested sub-package per use case in
           {{PROJECT_SHORT_CODE}}_UseCases. Copy the UC01Analysis
           skeleton below for each new use case.
         */

    package UC01Analysis {
        doc /* Functional analysis for use case UC01.
               Holds the action definitions, state definitions, and
               flow definitions that realise the use case.
               Rename this sub-package to match the real use case name.
             */

        // action def ExampleAction { ... }
        // state def ExampleState { ... }
    }
}
