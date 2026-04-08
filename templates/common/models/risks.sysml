// {{PROJECT_NAME}} — Risk Register
//
// Risk register for {{PROJECT_NAME}}. Holds standalone risk item defs
// with RiskInfo metadata applied, plus the severity and likelihood
// enumerations used across the project.
//
// Source: ISO/IEC TR 29110-5-6-2:2014 PM.O5, PM.1.11, PM.2.3, PM.3.1.
// RiskInfo metadata def is declared in @sysml2-metadata and imported
// here by name.
// Authoring help: @sysml2-metadata, @sysml2-model-structure Section 8

package {{PROJECT_SHORT_CODE}}_Risks {
    // When @sysml2-metadata is used in the project, import the RiskInfo
    // metadata def by name:
    // private import Metadata::RiskInfo;

    doc /* Risk register for {{PROJECT_NAME}}.
           Each risk is either:
             (a) a standalone item def declared inside this package,
                 with RiskInfo metadata applied, or
             (b) a RiskInfo metadata application on a requirement or
                 architecture element elsewhere in the model.
           Severity and likelihood use the five-level scales below.
         */

    enum def Severity {
        Low;
        Moderate;
        High;
        VeryHigh;
        Critical;
    }

    enum def Likelihood {
        Low;
        Moderate;
        High;
        VeryHigh;
        Critical;
    }

    enum def RiskStatus {
        Open;
        Mitigating;
        Mitigated;
        Accepted;
        Closed;
    }

    // Example standalone risk entry. Replace with real risks.
    // Uncomment once the RiskInfo import above is active.
    //
    // item def R_ExampleRisk {
    //     @RiskInfo {
    //         severity = Severity::High;
    //         likelihood = Likelihood::Moderate;
    //         status = RiskStatus::Open;
    //         owner = "systems";
    //     }
    //     attribute id : String = "R-0001";
    //     attribute description : String =
    //         "Example risk description. Replace with the real risk.";
    // }
}
