package ExampleSystemStories {
    private import VSE_Library::*;
    private import ExampleStories::*;

    #derive
    requirement SYS_901_Example : UserStory {
        @StoryMeta { points = 2; priority = Priority::high; status = StoryStatus::ready; }

        subject :>> system : ExampleSystem;
        stakeholder :>> role : Operator;

        attribute :>> capability = "deliver each reading to the display";
        attribute :>> benefit    = "the device is known to work";

        requirement :>> acceptance {
            requirement readingDelivered {
                doc /* Given the device takes a reading, when it sends the reading, then the display receives it within one second. */
            }
        }
    }

    #derivation connection sys901Derives {
        end #original ::> US_901_Example;
        end #derive   ::> SYS_901_Example;
    }
}
