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

               Pattern: each action def decomposes a use case into
               ordered steps with typed parameters. Each state def
               captures the operating modes of the system or a
               subsystem. Replace the examples below with real
               content.
             */

        // ─── Actions ──────────────────────────────────────────────
        //
        // An action def decomposes a use case into sequential steps.
        // Each nested action carries in/out parameters. Successions
        // define the execution order. See @sysml2-behaviour for
        // control nodes (decide, fork, join, merge).

        action def ExampleProcess {
            doc /* Example action decomposition. Replace with a real
                   process that realises the use case.
                 */

            action acquireData {
                doc /* First step: acquire raw data from a source. */
                out item rawData : Real;
            }

            action processData {
                doc /* Second step: process the acquired data. */
                in item data : Real;
                out item result : Boolean;
            }

            action reportResult {
                doc /* Third step: report the processed result. */
                in item outcome : Boolean;
            }

            // Successions define the execution order.
            // Each succession names its source and target explicitly.
            // Without successions the actions are unordered.
            first acquireData then processData;
            first processData then reportResult;
        }

        // ─── States ───────────────────────────────────────────────
        //
        // A state def captures the operating modes of the system or
        // a subsystem. Transitions connect states and may carry
        // guards or triggers. See @sysml2-behaviour for entry, do,
        // and exit activities.

        state def ExampleStates {
            doc /* Example state machine. Replace with real operating
                   modes for the subsystem this use case exercises.
                 */

            state idle {
                doc /* Initial state: waiting for input. */
            }

            state active {
                doc /* Processing state: system is performing work. */
            }

            state error {
                doc /* Fault state: an error condition was detected. */
            }

            transition idle_to_active
                first idle then active;

            transition active_to_error
                first active then error;

            transition error_to_idle
                first error then idle;
        }
    }
}
