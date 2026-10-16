package CleanResolved {
    private import CleanSystemStories::*;

    part def ExampleSystem;

    part deployment {
        part system : ExampleSystem;
        satisfy SYS_101_FirstReadingLatency by system;
    }
}
