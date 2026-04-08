// {{PROJECT_NAME}} — Interfaces
//
// Logical interfaces and the logical data schema used by those
// interfaces. Physical interfaces and shared hardware definitions
// belong in a shared model when the project federates; this package
// holds the logical view only.
//
// Source: Douglass 2016 Agile Systems Engineering, Fig 3.13
// InterfacesPkg; Douglass 2021 Agile MBSE Cookbook, Fig 1.35 Interfaces
// Package. Federation split per ASE 2016 Ch 8 Fig 8.4.
// Authoring help: @sysml2-modelling, @architecture-design

package {{PROJECT_SHORT_CODE}}_Interfaces {
    doc /* Logical interfaces for {{PROJECT_NAME}}.
           Each interface definition carries the data items that flow
           across it, the direction (in, out, inout), and a doc comment
           describing the interaction.
         */

    interface def ExampleInterface {
        doc /* Example logical interface.
               Replace with real interfaces as they are identified.
             */
    }
}
