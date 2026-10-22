package FixtureW2 {
    private import VSE_Library::*;

    requirement US_301_NoSubject : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_302_TwoSubjects : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        subject :>> system : OtherSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_303_SubjectAfterRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        stakeholder :>> role : Operator;
        subject :>> system : ExampleSystem;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_304_UntypedSubject : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_305_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }
}
