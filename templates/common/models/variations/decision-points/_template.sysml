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

    // Example: a decision over alarm storage strategy.
    variation part def AlarmStorageStrategy {
        variant part inMemoryRingBuffer;
        variant part embeddedSQLite;
        variant part externalTSDB;
    }

    // Cross-decision constraints (per §6.3.3) live on the
    // configurable system part def, not here. Use `assert constraint`
    // for "if A then B" rules across decisions.
}
