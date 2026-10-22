package FixtureS8Resolved {
    private import FixtureS8::*;

    part def ExampleSystem;

    part deployment {
        part system : ExampleSystem;
        satisfy US_186_SatisfiedWithoutScenario by system;
        satisfy US_188_SatisfiedWithScenario by system;
        satisfy US_189_SatisfiedWithoutFeature by system;
    }
}
