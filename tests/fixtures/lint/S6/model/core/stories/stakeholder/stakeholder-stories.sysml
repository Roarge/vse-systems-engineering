package FixtureS6 {
    private import VSE_Library::*;

    requirement US_161_OtherRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_162_OtherCapability : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_163_OtherBenefit : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_164_TwoWordRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : MaintenanceTechnician;

        attribute :>> capability = "calibrate   the sensor in the field";
        attribute :>> benefit    = "drift is corrected on site";
    }

    requirement US_165_WantWithoutTo : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "a daily summary of the readings";
        attribute :>> benefit    = "the week can be reviewed";
    }
}
