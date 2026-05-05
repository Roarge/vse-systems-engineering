// System Context (§3).
//
// Per methodology §3, this composite part owns the system part and
// every external actor with their interfaces and item flows. Actors
// are classified into four categories per §3.2.1: human, external
// systems, environmental effects, environmental impact.
//
// Well-formedness rules (§3.6):
//   1. Exactly one system part.
//   2. Every actor part def classified into one of the four categories.
//   3. Every interface connected to at least one actor.
//   4. Every item flow has a typed item.
//   5. Same `part def` reused for stakeholder and actor where they
//      coincide.

package {{PROJECT_NAME}}_Context {

    private import {{PROJECT_NAME}}_BaseArchitecture::*;
    private import {{PROJECT_NAME}}_Stakeholders::*;
    private import {{PROJECT_NAME}}_Domain::*;

    // System part (typically a specialisation of a Base Architecture
    // part def, or allocated to one). Replace with the project's
    // system part def.
    part def {{PROJECT_NAME}}_System :> AC5000_Platform {
        port operatorUI : OperatorUIPort;
        port deviceField : DeviceFieldPort;
    }

    // External system actor example.
    part def WeatherService;

    // Environmental effect actor example.
    part def AmbientWeather {
        attribute temperature : TemperatureValue;
        attribute precipitation : PrecipitationValue;
    }

    // Interface and item flow declarations live here.
    interface def OperatorUIInterface {
        end systemSide   : OperatorUIPort;
        end operatorSide : OperatorPort;
    }

    // Composite System Context part.
    part def {{PROJECT_NAME}}_Context_Composite {
        part system   : {{PROJECT_NAME}}_System;
        part operator : Operator;
        part weather  : WeatherService;
        part ambient  : AmbientWeather;

        interface uiLink : OperatorUIInterface
            connect system.operatorUI to operator.systemPort;

        // Add typed item flows here per §3.3.3.
    }

    // Placeholder port and item type declarations.
    port def OperatorUIPort;
    port def DeviceFieldPort;
    port def OperatorPort;
}
