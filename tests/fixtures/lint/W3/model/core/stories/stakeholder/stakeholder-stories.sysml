package FixtureW3 {
    private import VSE_Library::*;

    requirement US_311_ReadyWithoutRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_312_TwoRoles : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;
        stakeholder :>> role : Regulator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_313_UntypedRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::inProgress; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_314_BacklogWithoutRole : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::backlog; }

        subject :>> system : ExampleSystem;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }

    requirement US_315_Clean : UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "see the first reading";
        attribute :>> benefit    = "the device is known to work";
    }
}
