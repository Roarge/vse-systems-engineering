// {{PROJECT_NAME}} — Architectural Analysis
//
// Architectural trade studies. One nested sub-package per trade, holding
// the candidate architectures, the weighted assessment criteria, the
// scoring, and the sensitivity analysis.
//
// Source: Douglass 2016 Agile Systems Engineering, Fig 3.13
// ArchitecturePkg trade-off half; Douglass 2021 Agile MBSE Cookbook,
// Fig 1.35 Architectural Analysis Package.
// Authoring help: @architecture-design, @vse-trade-study-runner

package {{PROJECT_SHORT_CODE}}_ArchAnalysis {
    doc /* Architectural trade studies for {{PROJECT_NAME}}.
           Each trade study lives in its own nested sub-package, so
           that the selected architecture and the discarded candidates
           can be queried independently and retained for project audit.
           Copy the TradeStudy01 skeleton below for each new trade.
         */

    package TradeStudy01 {
        doc /* Example trade study.
               Decision: (describe the architectural decision).
               Candidates: (list two or more candidate architectures).
               Criteria: (list weighted assessment criteria).
               Dispatch: @vse-trade-study-runner scores each candidate
               against each criterion in isolation.
             */

        part def CandidateA {
            doc /* First candidate architecture. Describe its
                   distinguishing characteristics and trade-offs.
                 */
        }

        part def CandidateB {
            doc /* Second candidate architecture. Describe how it
                   differs from CandidateA.
                 */
        }

        analysis def CandidateScoring {
            doc /* Trade study scoring. The subject is the candidate
                   under analysis. Dispatch to @vse-trade-study-runner
                   to score each candidate against weighted criteria.
                 */
            subject candidate : CandidateA;
        }
    }
}
