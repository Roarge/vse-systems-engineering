// Variation decision points (§6.3.2).
//
// Each architectural decision is a `variation part def` whose
// `variant part`s are the candidate solutions. Variants implicitly
// subset the variation, so any variant is substitutable for it.
//
// Variations declared here are referenced from candidate-variants/
// (which holds the detailed variant attributes), trade-studies/
// (which scores them), and resolved/ (which redefines them in the
// chosen architecture).

package {{PROJECT_NAME}}_DecisionPoints {

    private import {{PROJECT_NAME}}_CandidateVariants::*;

    // Example: a decision over alarm storage strategy. Each variant part
    // is typed by the candidate part defs in candidate-variants/.
    variation part def AlarmStorageStrategy {
        variant part inMemoryRingBuffer : InMemoryRingBuffer;
        variant part embeddedSQLite     : EmbeddedSQLite;
        variant part externalTSDB       : ExternalTSDB;
    }

    // Cross-decision constraints (per §6.3.3) live on the
    // configurable system part def, not here. Use `assert constraint`
    // for "if A then B" rules across decisions.
}
