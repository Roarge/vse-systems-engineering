package CleanVerificationCases {
    private import CleanSystemStories::*;

    verification def VC_101_Latency {
        objective {
            verify SYS_101_FirstReadingLatency.acceptance;
        }
    }
}
