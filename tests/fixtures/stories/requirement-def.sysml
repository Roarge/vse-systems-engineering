// Only a requirement usage typed by UserStory, or by
// VSE_Library::UserStory, is a story. A definition that specialises
// UserStory, a usage that subsets one, and a usage typed by another
// library's UserStory are not.
package OtherLibrary {
    requirement def UserStory;
}

package RequirementDefFixture {
    private import VSE_Library::*;

    requirement def US_401_LegacyDefinition :> UserStory {
        attribute :>> capability = "keep the pre-4.0.0 definition form";
    }

    requirement US_402_Subsetting :> UserStory {
        attribute :>> capability = "subset a story instead of typing one";
    }

    requirement US_403_OtherLibrary : OtherLibrary::UserStory {
        doc /* Typed by a story definition from another library. */
    }

    requirement US_404_Qualified : VSE_Library::UserStory {
        attribute :>> capability = "name the story type with its package";
    }

    requirement US_405_Plain : UserStory {
        requirement :>> acceptance {
            doc /* Given a story usage, when the register is read,
                   then the story counts. */
        }
    }
}
