package CleanSystemStories {
    private import VSE_Library::*;

    #derive
    requirement SYS_101_FirstReadingLatency : VSE_Library::UserStory {
        @StoryMeta { points = 3; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "deliver the first reading within a bounded latency";
        attribute :>> benefit    = "the operator sees the device working at once";

        requirement :>> acceptance {
            requirement latencyMet {
                doc /* Given the device is switched on, when it takes a reading, then the reading is shown. */
            }
        }
    }
}
