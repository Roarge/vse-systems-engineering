package FixtureCompact {
    private import VSE_Library::*;

    requirement US_501_NoBenefit : UserStory { @StoryMeta { status = StoryStatus::backlog; } subject :>> system : ExampleSystem; stakeholder :>> role : Operator; attribute :>> capability = "see the first reading"; }

    requirement US_502_OtherRole : UserStory { @StoryMeta { status = StoryStatus::backlog; } subject :>> system : ExampleSystem; stakeholder :>> role : Operator; attribute :>> capability = "see the first reading"; attribute :>> benefit = "the device is known to work"; }

    requirement US_503_AttributesOnOneLine : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem; stakeholder :>> role : Operator;
        attribute :>> capability = "see the first reading"; attribute :>> benefit = "the device is known to work";

        requirement :>> acceptance {
            requirement firstReading {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }

    requirement US_504_Clean : UserStory { @StoryMeta { status = StoryStatus::ready; } subject :>> system : ExampleSystem; stakeholder :>> role : Operator; attribute :>> capability = "see the \"first\" reading"; attribute :>> benefit = "the device is known to work"; requirement :>> acceptance { requirement firstReading { doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */ } } }
}
