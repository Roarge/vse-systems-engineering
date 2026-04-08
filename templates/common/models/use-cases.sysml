// {{PROJECT_NAME}} — Use Cases
//
// Use cases and use case diagrams. Imports actors from
// {{PROJECT_SHORT_CODE}}_Actors.
//
// Source: Douglass 2021 Agile MBSE Cookbook, Fig 1.35 Use Case Diagrams
// Package. Use case driven elicitation is the AMBSE default per
// ambse-requirements.md.
// Authoring help: @sysml2-cases, @needs-and-requirements

package {{PROJECT_SHORT_CODE}}_UseCases {
    private import {{PROJECT_SHORT_CODE}}_Actors::Operator;

    doc /* Use cases for {{PROJECT_NAME}}.
           Each use case specifies a coherent piece of user-visible
           behaviour, the actors involved, and the flow of actions.
           When {{PROJECT_SHORT_CODE}}_FunctionalAnalysis is present
           (Canonical AMBSE tier), analysis of each use case lives in
           a nested sub-package there, one per use case.
         */

    use case def UC_ExampleUseCase {
        doc /* Example use case.
               Actor: Operator.
               Goal: (replace with the user goal).
               Flow: (basic flow and alternatives).
               Replace with a real use case.
             */
        subject operator : Operator;
    }
}
