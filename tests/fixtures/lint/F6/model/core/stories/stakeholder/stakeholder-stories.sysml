package FixtureF6 {
    private import VSE_Library::*;

    requirement US_251_NoNarrative : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_252_OutOfOrder : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_253_TextFirst : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_254_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }
}
