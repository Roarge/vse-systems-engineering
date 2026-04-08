// {{PROJECT_NAME}} — Model-Level Configuration Management (OPTIONAL)
//
// Optional top-level package holding model-level configuration items
// and baselines. Scaffolded only when project-setup is run with the
// CM opt-in.
//
// This package COMPLEMENTS the Project Plan Section 9 "Configuration
// Management Strategy" (PM.1.13 output) and the SEMP Section 4.3
// configuration management stub. Neither layer is complete alone:
//   - Project Plan Section 9 owns WHEN baselines are taken, WHO
//     authorises them, and the repository and backup rules.
//   - This package owns WHAT each baseline contains in a
//     machine-readable form that the Automator can query and
//     @traceability-guard can check.
//
// Source: ISO/IEC TR 29110-5-6-2:2014 PM.1.13, PM.1.18, PM.2.5, PM.O6,
// SR.O6. ConfigItem and Baseline metadata defs are declared in
// @sysml2-metadata and imported here by name.
// Authoring help: @sysml2-metadata, @sysml2-model-structure Section 7

package {{PROJECT_SHORT_CODE}}_CM {
    // When @sysml2-metadata is used in the project, import the metadata
    // defs by name:
    // private import Metadata::ConfigItem;
    // private import Metadata::Baseline;

    doc /* Model-level configuration management for {{PROJECT_NAME}}.
           Cross-reference: Project Plan Section 9 "Configuration
           Management Strategy" owns the governance and prose. This
           package owns the machine-readable CI and baseline data.
           A release tag on main names a baseline declared here.
         */

    // Initial baseline. Populate the scope list as CIs are identified.
    item def BL_INIT {
        doc /* Initial project baseline.
               Scope is empty at project start. As the project
               progresses, identify configuration items and add them
               to the scope of subsequent baselines
               (BL-SRS-0.1, BL-SRS-0.2, and so on).
             */
        attribute id : String = "BL-INIT";
        attribute date : String = "{{DATE}}";
        attribute description : String =
            "Initial project baseline for {{PROJECT_NAME}}.";
        // scope : <reference list of CIs frozen at this baseline>
        // supersedes : (empty for the initial baseline)
    }

    // Example application pattern for a ConfigItem on a requirement
    // elsewhere in the model (keep this comment, do not uncomment):
    //
    //   requirement def SR_SomeRequirement {
    //       @ConfigItem {
    //           ciId = "REQ-SYS-001";
    //           baselineId = "BL-SRS-0.3";
    //           state = Baselined;
    //           owner = "systems";
    //       }
    //       ...
    //   }
}
