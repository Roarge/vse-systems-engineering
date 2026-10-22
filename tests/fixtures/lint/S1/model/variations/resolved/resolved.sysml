package FixtureS1Resolved {
    private import FixtureS1::*;

    part def ExampleSystem;

    part deployment {
        part system : ExampleSystem;
        satisfy US_115_CommentsOnly by system;
    }
}
