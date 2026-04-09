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
           This package holds port definitions (data types for
           communication points) and interface definitions (connection
           types between ports).

           Port definitions declare the attributes that flow through a
           port. Parts in {{PROJECT_SHORT_CODE}}_ArchDesign reference
           these port defs on their port features.

           Interface definitions declare how two ports connect. They
           carry end features naming the port types at each side. Use
           interface usages in {{PROJECT_SHORT_CODE}}_ArchDesign to wire
           parts together.
         */

    // ─── Port Definitions ─────────────────────────────────────────
    //
    // Each port def declares the data items that flow through a
    // communication point. Parts reference these as port types.
    // Replace the example below with real port definitions.

    port def ExampleInterface {
        doc /* Example port definition carrying typed data items.
               Replace with real data attributes as they are
               identified. Attributes on a port def describe what
               crosses the interface.
             */
        attribute value : Real;
        attribute status : Boolean;
    }

    // Add further port definitions here, one per logical data type:
    // port def CommandPort { attribute commandId : String; }
    // port def StatusPort { attribute healthy : Boolean; }
}
