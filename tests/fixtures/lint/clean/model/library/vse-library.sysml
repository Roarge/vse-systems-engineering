// A reduced copy of the VSE library. The definition of UserStory is
// neither a story nor an unreadable story declaration.
package VSE_Library {
    abstract requirement def StakeholderNeed;

    requirement def UserStory :> StakeholderNeed {
        doc /* A story is a usage:
               requirement US_042_AckFromDashboard : UserStory { ... } */
        subject system;
        stakeholder role;
        requirement acceptance[0..*] {
            doc /* One acceptance criterion in Given/When/Then form. */
        }
    }

    metadata def StoryMeta;
}
