package OtherLibrary {
    requirement def UserStory;
}

package FixtureS9 {
    private import VSE_Library::*;

    requirement def US_191_Definition :> UserStory {
        attribute :>> capability = "keep the definition form";
    }

    requirement US_192_Subsetting :> UserStory {
        attribute :>> capability = "subset a story";
    }

    requirement US_193_OtherLibrary : OtherLibrary::UserStory {
        attribute :>> capability = "use another library";
    }

    requirement US_195_NestedType : UserStory::Nested {
        attribute :>> capability = "type by a member of UserStory";
    }

    requirement US_194_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }
}
