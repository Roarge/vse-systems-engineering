// A story declaration may wrap across lines, and metadata such as
// #derive may sit on the line before it.
package MultilineFixture {
    private import VSE_Library::*;
    private import RequirementDerivation::*;

    #derive
    requirement
        US_501_Wrapped
        :
        UserStory
    {
        attribute :>> capability =
            "wrap the declaration over several lines";
    }

    #derive requirement US_502_SameLineMetadata : UserStory {
        attribute :>> capability = "keep the metadata on the same line";
    }
}
